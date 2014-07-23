within Buildings.Rooms;
model CFD
  "Model of a room in which the air is computed using Computational Fluid Dynamics (CFD)"
  extends Buildings.Rooms.BaseClasses.RoomHeatMassBalance(
  redeclare BaseClasses.CFDAirHeatMassBalance air(
    final cfdFilNam = cfdFilNam,
    final useCFD=useCFD,
    final samplePeriod=samplePeriod,
    final startTime=startTime,
    final haveSensor=haveSensor,
    final nSen=nSen,
    final sensorName=sensorName,
    final portName=portName,
    final uSha_fixed=uSha_fixed),
    final energyDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial,
    massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial);

  parameter Boolean useCFD = true
    "Set to false to deactivate the CFD computation and use instead yFixed as output"
    annotation(Evaluate = true);

  parameter Modelica.SIunits.Time samplePeriod(min=100*Modelica.Constants.eps)
    "Sample period of component"
    annotation(Dialog(group = "Sampling"));

  parameter Real uSha_fixed[nConExtWin] = zeros(nConExtWin)
    "Constant control signal for the shading device (0: unshaded; 1: fully shaded)";

  parameter String sensorName[:] = {""}
    "Names of sensors as declared in the CFD input file";
  parameter String portName[nPorts]
    "Names of fluid ports as declared in the CFD input file";
  parameter String cfdFilNam "CFD input file name" annotation (Dialog(
        __Dymola_loadSelector(caption=
            "Select CFD input file")));
  Modelica.Blocks.Interfaces.RealOutput yCFD[nSen] if
       haveSensor "Sensor for output from CFD"
    annotation (Placement(transformation(
     extent={{460,110},{480,130}}), iconTransformation(extent={{200,110},{220, 130}})));

protected
  BaseClasses.CFDHeatGain heaGai(final AFlo=AFlo)
    "Model to convert internal heat gains"
    annotation (Placement(transformation(extent={{-220,90},{-200,110}})));

protected
  final parameter Boolean haveSensor = Modelica.Utilities.Strings.length(sensorName[1]) > 0
    "Flag, true if the model has at least one sensor";
  final parameter Integer nSen(min=0) = size(sensorName, 1)
    "Number of sensors that are connected to CFD output";
 parameter Modelica.SIunits.Time startTime(fixed=false)
    "First sample time instant.";

  Modelica.Blocks.Sources.Constant conSha[nConExtWin](final k=uSha_fixed) if
       haveShade "Constant signal for shade"
    annotation (Placement(transformation(extent={{-260,170},{-240,190}})));

initial equation
  startTime = time; // fixme: don't mix equations with graphical modeling

equation
  connect(qGai_flow, heaGai.qGai_flow) annotation (Line(
      points={{-280,80},{-250,80},{-250,100},{-222,100}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(heaGai.QRad_flow, add.u2) annotation (Line(
      points={{-198,106},{-152,106},{-152,114},{-142,114}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(air.QCon_flow, heaGai.QCon_flow) annotation (Line(
      points={{39,-135},{-14,-135},{-14,-92},{-190,-92},{-190,100},{-198,100}},
      color={0,0,127},
      smooth=Smooth.None));

  connect(air.QLat_flow, heaGai.QLat_flow) annotation (Line(
      points={{39,-138},{-18,-138},{-18,-94},{-194,-94},{-194,94},{-198,94},{
          -198,94}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(air.yCFD, yCFD) annotation (Line(
      points={{61,-142.5},{61,-206},{440,-206},{440,120},{470,120}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conSha.y, conExtWin.uSha) annotation (Line(
      points={{-239,180},{328,180},{328,62},{281,62}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conSha.y, bouConExtWin.uSha) annotation (Line(
      points={{-239,180},{328,180},{328,64},{351,64}},
      color={0,0,127},
      pattern=LinePattern.None,
      smooth=Smooth.None));
  connect(conSha.y, conExtWinRad.uSha) annotation (Line(
      points={{-239,180},{420,180},{420,-42},{310.2,-42},{310.2,-25.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(irRadGai.uSha,conSha.y)
                             annotation (Line(
      points={{-100.833,-22.5},{-112,-22.5},{-112,180},{-239,180}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conSha.y, radTem.uSha) annotation (Line(
      points={{-239,180},{-112,180},{-112,-62},{-100.833,-62},{-100.833,-62.5}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conSha.y, shaSig.u) annotation (Line(
      points={{-239,180},{-228,180},{-228,160},{-222,160}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(air.uSha,conSha.y)  annotation (Line(
      points={{39.6,-120},{28,-120},{28,180},{-239,180}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-200},{200,200}}),
                               graphics={Rectangle(
          extent={{-140,138},{140,78}},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Bitmap(
          extent={{-140,162},{150,-176}},
          imageSource=
              "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",
          fileName="modelica://Buildings/CFD.png"),
                                          Text(
          extent={{162,98},{196,140}},
          lineColor={0,0,127},
          textString="yCFD"),
        Text(
          extent={{-86,-14},{0,16}},
          lineColor={0,0,0},
          textString="air"),
        Text(
          extent={{-102,-50},{-22,-26}},
          lineColor={0,0,0},
          textString="radiation"),
        Text(
          extent={{-114,-134},{-36,-116}},
          lineColor={0,0,0},
          textString="surface")}),
    Documentation(info="<html>
<p>
Room model that the air is computed by the CFD program through the coupled simulation.
Currently, the supported CFD program is:
</p>
<ul>
<li>
Fast Fluid Dynamics (FFD) programs <a href=\"#ZUO2010\">(Zuo 2010)</a>. 
</li>
</ul>
<p>
See 
<a href=\"modelica://Buildings.Rooms.UsersGuide.CFD\">Buildings.Rooms.UsersGuide.CFD</a>
for detailed explanations.
</p>
<h4>References</h4>
<p>
<a NAME=\"ZUO2010\"/> 
Wangda Zuo. Advanced simulations of air distributions in buildings. Ph.D. Thesis, School of Mechanical Engineering, Purdue University, 2010.
</p>
</html>",
revisions="<html>
<ul>
<li>
August 1, 2013, by Michael Wetter and Wangda Zuo:<br/>
First Implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-260,-220},{460,
            200}}), graphics));
end CFD;
