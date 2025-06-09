package vct.avalanche

import com.code_intelligence.jazzer.Jazzer
import com.code_intelligence.jazzer.api.BugDetectors
import com.code_intelligence.jazzer.instrumentor.CoverageRecorder
import com.code_intelligence.jazzer.third_party.org.jacoco.core.data.ExecutionDataReader
import com.google.common.reflect.ClassPath
import jakarta.mail.{Message, Session}
import jakarta.mail.internet.{InternetAddress, MimeBodyPart, MimeMessage, MimeMultipart}
import ujson.Obj
import vct.main.{BuildInfo, Main}
import vct.options.Options

import java.io.{BufferedReader, ByteArrayInputStream, ByteArrayOutputStream, DataOutputStream, File, InputStreamReader, PrintWriter, StringWriter}
import java.net.http.HttpResponse.BodyHandlers
import java.net.http.{HttpClient, HttpRequest}
import java.net.{ServerSocket, Socket, URI}
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.util.{Base64, Date, Properties}
import java.util.concurrent.atomic.AtomicReference
import scala.annotation.nowarn
import scala.collection.mutable

object AValAnCHE {
  private val latest = new AtomicReference[Obj]()

  private class AvalancheThread(s: Socket) extends Thread {
    override def run(): Unit = {
      val HEADER = "HTTP/1.0 %s AValAnCHE\r\nContent-Type: %s\r\n\r\n"
      val is = s.getInputStream
      val os = s.getOutputStream

      val br = new BufferedReader(new InputStreamReader(is))

      val req = br.readLine().split(" ")

      assert(req.size == 3)
      assert(req(0) == "GET")
      assert(req(2).startsWith("HTTP/"))

      val pw = new PrintWriter(os, true)

      if (req(1) == "/") {
        pw.format(HEADER, 200, "text/html")
        getClass.getResourceAsStream("avalanche.html").transferTo(os)
      } else if (req(1) == "/events") {
        pw.format(HEADER, 200, "text/event-stream")

        while (true) {
          latest.synchronized {
            latest.wait()
            pw.format("event: message\ndata: %s\n\n", latest.get())
          }
        }
      } else {
        pw.format(HEADER, 404, "text/plain")
        pw.print("404 Not Found")
      }

      s.close()
    }
  }

  private class AcceptThread(port: Int) extends Thread {
    override def run(): Unit = {
      val accept = new ServerSocket(port)

      while (true) {
        val client = accept.accept()
        new AvalancheThread(client).start()
      }
    }
  }

  private val httpClient = HttpClient.newHttpClient()
  private val b64 = Base64.getUrlEncoder
  private var total = 0
  private val boot = System.currentTimeMillis()
  private var record = 0
  private var find = System.currentTimeMillis()
  private val findings = mutable.Map[String, Obj]()

  @nowarn("cat=unused") // Not unused; called indirectly by Jazzer
  def fuzzerTestOneInput(seed: Array[Byte]): Unit = {
    if (total == 0) {
      ClassPath.from(this.getClass.getClassLoader).getAllClasses.forEach(x => {
        try {
          if (x.getSimpleName != "Zer")
            x.load().newInstance().toString
        } catch {
          case e: Throwable => {
          }
        }
      })
    }

    total += 1
    val f = File.createTempFile("avalanche", ".txt")

    BugDetectors.allowNetworkConnections()
    val httpRequest = HttpRequest.newBuilder().uri(new URI("http", null, "localhost", 10070, "/", b64.encodeToString(seed), null)).build()

    val response = httpClient.send(httpRequest, BodyHandlers.ofFile(f.toPath))

    val lang = response.headers().firstValue("Content-Type").orElse("") match {
      case "text/x-java" => "--lang=java"
      case "text/x-c" => "--lang=c"
      case "text/x-cpp" => "--lang=cpp"
      case "text/x-llvm" => "--lang=llvm"
      case _ => "--lang=pvl"
    }

    val options = Options.parse(Array(lang, "--skip-backend", f.toString)).get

    val text = Files.readString(f.toPath, StandardCharsets.ISO_8859_1)

    try {
      Main.runMode(options.mode, options)
    } catch {
      case e: Throwable =>
        val sb = new ByteArrayOutputStream()
        val db = new DataOutputStream(sb)

        var f = e
        while (f != null) {
          f.getStackTrace.foreach(b => db.writeInt(b.hashCode))
          f = f.getCause
        }

        val t = b64.encodeToString(sb.toByteArray)

        if (!findings.contains(t)) {
          val sw = new StringWriter()
          val ps = new PrintWriter(sw)
          e.printStackTrace(ps)

          // TODO extract into own thing (own thread?)
          val props = new Properties()
          props.setProperty("mail.smtp.host", "localhost") // TODO configurable
          props.setProperty("mail.smtp.port", "1025") // TODO configurable
          val session = Session.getInstance(props, null)

          val multipart = new MimeMultipart()
          val textBody = new MimeBodyPart()
          val psw = new StringWriter()
          val pw = new PrintWriter(psw)
          pw.println("AValAnCHE has found a crash with the following stack trace:")
          pw.println()
          pw.println(sw)
          pw.println()
          pw.format("Name: %s\n", BuildInfo.name)
          pw.format("Version: %s\n", BuildInfo.version)
          pw.format("Branch: %s\n", BuildInfo.currentBranch)
          pw.format("Commit: %s (%s)\n", BuildInfo.currentShortCommit, if (BuildInfo.gitHasChanges == "false") "clean" else "dirty")
          pw.format("Scala: %s\n", BuildInfo.scalaVersion)
          pw.format("Silver: %s\n", BuildInfo.silverCommit)
          pw.format("Carbon: %s\n", BuildInfo.carbonCommit)
          pw.format("Silicon: %s\n", BuildInfo.siliconCommit)
          textBody.setText(psw.toString, "utf-8")
          multipart.addBodyPart(textBody)

          val reproducer = new MimeBodyPart()
          reproducer.setContent(text, "text/plain")
          reproducer.setFileName("ex." + lang.split('=')(1))
          multipart.addBodyPart(reproducer)

          val dest = new InternetAddress("list@example.com") // TODO configurable

          val message = new MimeMessage(session)
          message.setSubject(e.getClass.getSimpleName + ": " + e.getMessage.replaceAll("\n", " "))
          message.setFrom(new InternetAddress("avalanche@example.com", "AValAnCHE")) // TODO configurable
          message.setRecipient(Message.RecipientType.TO, dest)
          message.addHeader("Auto-Submitted", "auto-generated")
          message.setSentDate(new Date())
          message.setContent(multipart)

          val transport = session.getTransport
          transport.connect()
          transport.sendMessage(message, Array(dest))

          findings.getOrElseUpdate(t, Obj(
            "what" -> e.getClass.getSimpleName,
            "message" -> e.getMessage,
            "first" -> System.currentTimeMillis(),
            "stack" -> sw.toString,
            "text" -> text,
            "count" -> 1))
        } else {
          findings(t).update("count", _.num + 1)
        }
    }

    var covered = 0
    var probes = 0
    val jacoco_out = new ByteArrayOutputStream()
    CoverageRecorder.dumpJacocoCoverage(jacoco_out, Array())
    val ba = jacoco_out.toByteArray
    val jacoco_in = new ByteArrayInputStream(ba)
    val edr = new ExecutionDataReader(jacoco_in)
    edr.setSessionInfoVisitor(_ => { })
    edr.setExecutionDataVisitor(data => {
      probes += data.getProbes.length
      if (data.hasHits) {
        covered += data.getProbes.count(p => p)
      }
    })
    edr.read()

    if (covered > record) {
      record = covered
      find = System.currentTimeMillis()
    }

    latest.synchronized {
      latest.set(
        Obj(
          "lang" -> lang,
          "text" -> text,
          "findings" -> findings,
          "stats" -> Obj(
            "total" -> total,
            "boot" -> boot,
            "now" -> System.currentTimeMillis(),
            "find" -> find,
            "covered" -> covered,
            "probes" -> probes)))
      latest.notifyAll()
    }

    f.delete()
  }

  def main(args: Array[String]): Unit = {
    new AcceptThread(2341).start()

    try {
      Jazzer.main(Array("--target_class=vct.avalanche.AValAnCHE", "--keep_going=0", "--instrumentation_includes=vct.**:hre.**", "--instrumentation_excludes=vct.avalanche.**"))
    } finally {
      System.exit(1)
    }
  }
}
