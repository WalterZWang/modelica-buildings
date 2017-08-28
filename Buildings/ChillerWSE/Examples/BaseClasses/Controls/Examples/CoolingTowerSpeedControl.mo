within Buildings.ChillerWSE.Examples.BaseClasses.Controls.Examples;
model CoolingTowerSpeedControl
  "Test the model ChillerWSE.Examples.BaseClasses.CoolingTowerSpeedControl"
  extends Modelica.Icons.Example;

  parameter Modelica.Blocks.Types.SimpleController controllerType=
    Modelica.Blocks.Types.SimpleController.PID
    "Type of controller"
    annotation(Dialog(tab="Controller"));
  parameter Real k(min=0, unit="1") = 1
    "Gain of controller"
    annotation(Dialog(tab="Controller"));
  parameter Modelica.SIunits.Time Ti(min=Modelica.Constants.small)=0.5
    "Time constant of Integrator block"
     annotation (Dialog(enable=
          (controllerType == Modelica.Blocks.Types.SimpleController.PI or
          controllerType == Modelica.Blocks.Types.SimpleController.PID),tab="Controller"));
  parameter Modelica.SIunits.Time Td(min=0)=0.1
    "Time constant of Derivative block"
     annotation (Dialog(enable=
          (controllerType == Modelica.Blocks.Types.SimpleController.PD or
          controllerType == Modelica.Blocks.Types.SimpleController.PID),tab="Controller"));
  parameter Real yMax(start=1)=1
   "Upper limit of output"
    annotation(Dialog(tab="Controller"));
  parameter Real yMin=0
   "Lower limit of output"
    annotation(Dialog(tab="Controller"));

  Buildings.ChillerWSE.Examples.BaseClasses.Controls.CoolingTowerSpeedControl
    cooTowSpeCon(controllerType=Modelica.Blocks.Types.SimpleController.PI)
    "Cooling tower speed controller"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Blocks.Sources.Sine CHWST(
    amplitude=2,
    freqHz=1/360,
    offset=273.15 + 5)
    "Chilled water supply temperature"
    annotation (Placement(transformation(extent={{-60,-80},{-40,-60}})));
  Modelica.Blocks.Sources.Constant CWSTSet(k=273.15 + 20)
    "Condenser water supply temperature setpoint"
    annotation (Placement(transformation(extent={{-60,80},{-40,100}})));
  Modelica.Blocks.Sources.Sine CWST(
    amplitude=5,
    freqHz=1/360,
    offset=273.15 + 20)
    "Condenser water supply temperature"
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
  Modelica.Blocks.Sources.Constant CHWSTSet(k=273.15 + 6)
    "Chilled water supply temperature setpoint"
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
  Modelica.Blocks.Sources.CombiTimeTable cooMod(
    table=[0,0;
           360,0;
           360,1;
           720,1;
           720,2])
    "Cooling mode"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
equation
  connect(CWSTSet.y, cooTowSpeCon.CWST_set)
    annotation (Line(points={{-39,90},{
          -22,90},{-22,88},{-22,22},{-22,10},{-12,10}}, color={0,0,127}));
  connect(cooMod.y[1], cooTowSpeCon.cooMod)
    annotation (Line(points={{-39,50},{-26,50},{-26,5.55556},{-12,5.55556}},
      color={0,0,127}));
  connect(CHWSTSet.y, cooTowSpeCon.CHWST_set)
    annotation (Line(points={{-39,10},{-32,10},{-32,1.11111},{-12,1.11111}},
      color={0,0,127}));
  connect(CWST.y, cooTowSpeCon.CWST)
    annotation (Line(points={{-39,-30},{-32, -30},{-32,-3.33333},{-12,-3.33333}},
      color={0,0,127}));
  connect(CHWST.y, cooTowSpeCon.CHWST)
    annotation (Line(points={{-39,-70},{-32,-70},{-24,-70},
      {-24,-7.77778},{-12,-7.77778}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    __Dymola_Commands(file=
          "Resources/Scripts/Dymola/ChillerWSE/Examples/BaseClasses/Controls/Examples/CoolingTowerSpeedControl.mos"
        "Simulate and Plot"),
    Documentation(info="<html>
<p>
This example tests the controller for the cooling tower fan speed. Detailed control logic can be found in 
<a href=\"modelica://Buildings.ChillerWSE.Examples.BaseClasses.Controls.CoolingTowerSpeedControl\">
Buildings.ChillerWSE.Examples.BaseClasses.Controls.CoolingTowerSpeedControl</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
August 25, 2017, by Yangyang Fu:<br>
First implementation.
</li>
</ul>
</html>"));
end CoolingTowerSpeedControl;
