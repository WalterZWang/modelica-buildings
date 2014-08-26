within Buildings.Electrical.AC.ThreePhasesBalanced.Sensors;
model Probe "Model of a probe that measures RMS voltage and angle"
  extends OnePhase.Sensors.Probe(
  redeclare Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n term,
  V_nominal = 480);
  annotation (Documentation(info="<html>
<p>
This model represents a probe that measures the RMS voltage and the angle
of the voltage phasor (in degrees) at a given point.
</p>
<p>
Given a reference voltage the model computes also the voltage in per unit.
</p>
</html>", revisions="<html>
<ul>
<li>
August 25, 2014, by Marco Bonvini:<br/>
Created model and documentation.
</li>
</ul>
</html>"));
end Probe;
