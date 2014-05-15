within Buildings.Electrical.DC.Loads;
model Conductor "Model of a generic DC load"
    extends Buildings.Electrical.Interfaces.PartialLoad(redeclare package
      PhaseSystem = PhaseSystems.TwoConductor, redeclare Interfaces.Terminal_n
      terminal);
    Modelica.SIunits.Voltage absDV;
equation
  absDV = abs(terminal.v[1]-terminal.v[2]);

  if linear then
    //terminal.i[1] + P*(2/(1.1*V_nominal) - (terminal.v[1]-terminal.v[2])/(1.1*V_nominal)^2) = 0;

    if absDV <= (8/9)*V_nominal then
      terminal.i[1] + P*(2/(0.8*V_nominal) - (terminal.v[1]-terminal.v[2])/(0.8*V_nominal)^2) = 0;
    elseif absDV >= (12/11)*V_nominal then
      terminal.i[1] + P*(2/(1.2*V_nominal) - (terminal.v[1]-terminal.v[2])/(1.2*V_nominal)^2) = 0;
    else
      terminal.i[1] + P*(2/V_nominal - (terminal.v[1]-terminal.v[2])/V_nominal^2) = 0;
    end if;

  else
    PhaseSystem.activePower(terminal.v, terminal.i) + P = 0;
  end if;
  sum(i) = 0;
  annotation (
    Documentation(info="<html>
<p>
Model of a constant conductive load.
</p>
<p>
The model computes the power as
<code>P_nominal = v &nbsp; i</code>,
where <i>v</i> is the voltage and <i>i</i> is the current.
</p>
<p>
If the component consumes power, then <code>P_nominal &lt; 0</code>.
If it feeds power into the electrical grid, then <code>P_nominal &gt; 0</code>.
</p>
</html>", revisions="<html>
<ul>
<li>
February 1, 2013, by Thierry S. Nouidui:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}},
        grid={2,2}), graphics={
          Rectangle(
            extent={{-70,30},{70,-30}},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            lineColor={0,0,255}),
          Rectangle(extent={{-70,30},{70,-30}}, lineColor={0,0,255}),
          Line(points={{-90,0},{-70,0}}, color={0,0,255}),
          Text(
            extent={{-152,87},{148,47}},
            textString="%name",
            lineColor={0,0,255}),
          Text(
            extent={{-144,-38},{142,-70}},
            lineColor={0,0,0},
            textString="G=%G")}),
    Diagram(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}},
        grid={2,2}), graphics={
          Line(points={{-96,0},{-70,0}}, color={0,0,255}),
          Line(points={{70,0},{96,0}}, color={0,0,255}),
          Rectangle(extent={{-70,30},{70,-30}}, lineColor={0,0,255})}));
end Conductor;