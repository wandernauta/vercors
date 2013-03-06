
package semper.sil.verifier

import semper.sil.ast.Program

/** An abstract class for verifiers of SIL programs.
  *
  * @author Stefan Heule
  */
trait Verifier {

  /** The name of this verifier (all-lowercase, to be used to uniquely identify this verifier). */
  def name: String

  /** Returns the version of the verifier. */
  def version: String

  /** Returns the copyright string of this verifier, e.g., "(c) 2013 Name" */
  def copyright: String

  /**
   * Returns the dependencies.  A dependency could be any library or stand-alone
   * tool that this verifier relies on, either directly or indirectly.  Typically only other
   * tools in the verification tool-chain are included here which can easily influence the
   * verification outcome.
   */
  def dependencies: Seq[Dependency]

  /** Set the command-line arguments to be used in this verifier. */
  def commandLineArgs(options: Seq[String])

  /** Verifies a given SIL program and returns a sequence of ''verification errors''.
    *
    * @param program The program to be verified.
    * @return The verification result.
    */
  def verify(program: Program): VerificationResult
}

/** A description of a dependency of a verifier. */
trait Dependency {
  /** The name of the dependency. */
  def name: String

  /** The version of this dependency. */
  def version: String

  /** The location of this dependency.  Typically a path. */
  def location: String
}