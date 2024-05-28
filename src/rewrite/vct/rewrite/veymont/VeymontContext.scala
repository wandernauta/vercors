package vct.rewrite.veymont

import hre.util.ScopedStack
import vct.col.ast.{
  Choreography,
  Class,
  Communicate,
  Endpoint,
  Program,
  Variable,
}
import vct.col.rewrite.Generation

trait VeymontContext[Pre <: Generation] {
  object mappings {
    var program: Program[Pre] = null

    lazy val choreographyToCommunicates
        : Map[Choreography[Pre], Seq[Communicate[Pre]]] =
      choreographies.map { c =>
        (c, c.collect { case comm: Communicate[Pre] => comm }.toIndexedSeq)
      }.toMap
    lazy val allEndpoints = choreographies.flatMap { _.endpoints }
    lazy val endpointToChoreography: Map[Endpoint[Pre], Choreography[Pre]] =
      choreographies.flatMap { chor => chor.endpoints.map(ep => (ep, chor)) }
        .toMap
    lazy val endpointClassToEndpoint: Map[Class[Pre], Endpoint[Pre]] =
      choreographies.flatMap { chor =>
        chor.endpoints.map(endpoint => (endpoint.cls.decl, endpoint))
      }.toMap
  }

  lazy val choreographies: Seq[Choreography[Pre]] =
    mappings.program.collect { case c: Choreography[Pre] => c }.toIndexedSeq

  def communicatesOf(chor: Choreography[Pre]) =
    mappings.choreographyToCommunicates(chor)
  def isEndpointClass(c: Class[Pre]): Boolean =
    mappings.endpointClassToEndpoint.contains(c)
  def choreographyOf(c: Class[Pre]): Choreography[Pre] =
    mappings.endpointToChoreography(mappings.endpointClassToEndpoint(c))
  def endpointOf(c: Class[Pre]): Endpoint[Pre] =
    mappings.endpointClassToEndpoint(c)
  def isChoreographyParam(v: Variable[Pre]): Boolean =
    choreographies.exists { chor => chor.params.contains(v) }

  val currentChoreography = ScopedStack[Choreography[Pre]]()
  val currentEndpoint = ScopedStack[Endpoint[Pre]]()

  def inChoreography: Boolean =
    currentChoreography.nonEmpty && currentEndpoint.isEmpty
  def inEndpoint: Boolean =
    currentChoreography.nonEmpty && currentEndpoint.nonEmpty

  object InChor {
    def unapply[T](t: T): Option[(Choreography[Pre], T)] =
      if (inChoreography)
        Some((currentChoreography.top, t))
      else
        None
    def unapply: Option[Choreography[Pre]] =
      if (inChoreography)
        currentChoreography.topOption
      else
        None
  }

  object InEndpoint {
    def unapply[T](t: T): Option[(Choreography[Pre], Endpoint[Pre], T)] =
      if (inEndpoint)
        Some((currentChoreography.top, currentEndpoint.top, t))
      else
        None
    def unapply: Option[(Choreography[Pre], Endpoint[Pre])] =
      if (inEndpoint)
        Some((currentChoreography.top, currentEndpoint.top))
      else
        None
  }
}
