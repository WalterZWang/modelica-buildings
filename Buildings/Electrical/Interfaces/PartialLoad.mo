within Buildings.Electrical.Interfaces;
partial model PartialLoad "Partial model for a generic load"
  import Buildings.Electrical.Types.Assumption;
  replaceable package PhaseSystem =
      Buildings.Electrical.PhaseSystems.PartialPhaseSystem constrainedby
    Buildings.Electrical.PhaseSystems.PartialPhaseSystem "Phase system"
    annotation (choicesAllMatching=true);
  Modelica.SIunits.Voltage v[:](each start = V_nominal) = terminal.v;
  Modelica.SIunits.Current i[:](each start = P_nominal/V_nominal)= terminal.i;
  Modelica.SIunits.Power S[PhaseSystem.n] = PhaseSystem.phasePowers_vi(v, i)
    "Phase powers";
  Modelica.SIunits.Power P
    "Power of the load (negative if consumed, positive if fed into the electrical grid)";
  parameter Boolean linear = false
    "If =true introduce a linearization in the load"                                                    annotation(evaluate=true,Dialog(group="Modelling assumption"));
  parameter Buildings.Electrical.Types.Assumption mode(
    min=Assumption.FixedZ_steady_state,
    max=Assumption.VariableZ_P_inputFile)=Assumption.VariableZ_P_inputFile
    "Parameters that specifies the mode of the load (e.g., steady state, dynamic, prescribed power consumption, etc.)"
                                                                                                        annotation(evaluate=true,Dialog(group="Modelling assumption"));
  parameter Modelica.SIunits.Power P_nominal(start=0)
    "Nominal power (negative if consumed, positive if generated)"  annotation(evaluate=true,Dialog(group="Nominal conditions",
        enable = mode <> Assumption.VariableZ_P_input));
  parameter Modelica.SIunits.Voltage V_nominal(min=0, start=220)
    "Nominal voltage (V_nominal >= 0)"  annotation(evaluate=true, Dialog(group="Nominal conditions", enable = (mode==Assumptionm.FixedZ_dynamic or linear)));
  Modelica.Blocks.Interfaces.RealInput y if mode==Assumption.VariableZ_y_input
    "Fraction of the nominal power consumed"                       annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=180,
        origin={100,0}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=180,
        origin={100,0})));
  Modelica.Blocks.Interfaces.RealInput Pow(unit="W") if mode==Assumption.VariableZ_P_input
    "Power consumed"                       annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=180,
        origin={100,0}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=180,
        origin={100,0})));
  parameter String fileName = "modelica://Buildings/Resources/Data/Electrical/Benchmark/SLP_33buildings.mat"
    "Name of the file (path reference from modelica://)"
     annotation(Dialog(tab="Data from file", group="Details", enable = mode == Buildings.Electrical.Assumption.Assumption.VariableZ_P_inputFile));
  parameter String tableName = "SLP_33buildings"
    "Name of the table contained in the .txt or .mat file"
     annotation(Dialog(tab="Data from file", group="Details", enable = mode == Buildings.Electrical.Assumption.Assumption.VariableZ_P_inputFile));
  parameter Integer colNumber = 2
    "Index of the column that contains the load data"
     annotation(Dialog(tab="Data from file", group="Details", enable = mode == Buildings.Electrical.Assumption.Assumption.VariableZ_P_inputFile));
  parameter Boolean invertSign = false
    "If true the sign of the data stored in the files are changed"
     annotation(Dialog(tab="Data from file", group="Details", enable = mode == Buildings.Electrical.Assumption.Assumption.VariableZ_P_inputFile));
  Modelica.Blocks.Sources.CombiTimeTable load_fromFile(
    tableOnFile = mode==Assumption.VariableZ_P_inputFile,
    tableName = tableName,
    table = fill(0.0, 1, 2),
    columns = {colNumber},
    fileName = fName);
  replaceable Buildings.Electrical.Interfaces.Terminal terminal(redeclare
      package PhaseSystem = PhaseSystem) "Generalised terminal"
    annotation (Placement(transformation(extent={{-108,-8},{-92,8}}),
        iconTransformation(extent={{-108,-8},{-92,8}})));
protected
  parameter String fName = Buildings.BoundaryConditions.WeatherData.BaseClasses.getAbsolutePath(fileName);
  Modelica.Blocks.Interfaces.RealInput y_
    "Hidden value of the input load for the conditional connector";
  Modelica.Blocks.Interfaces.RealInput Pow_
    "Hidden value of the input power for the conditional connector";
  Real load(min=eps, max=1)
    "Internal representation of control signal, used to avoid singularity";
  constant Real eps = 1E-10
    "Small number used to avoid a singularity if the power is zero";
  constant Real oneEps = 1-eps
    "Small number used to avoid a singularity if the power is zero";
equation
  assert(y_>=0 and y_<=1+eps, "The power load fraction P (input of the model) must be within [0,1]");

  // Connection between the conditional and inner connector
  connect(y,y_);
  connect(Pow,Pow_);

  // If the power is fixed, inner connector value is equal to 1
  if mode==Assumption.FixedZ_steady_state or mode==Assumption.FixedZ_dynamic or mode==Assumption.VariableZ_P_inputFile then
    y_   = 1;
    Pow_ = P_nominal;
  elseif mode==Assumption.VariableZ_P_input then
    y_ = 1;
  elseif mode==Assumption.VariableZ_y_input then
    Pow_ = 0;
  end if;

  // Value of the load, depending on the type: fixed or variable
  if mode==Assumption.VariableZ_y_input then
    load = eps + oneEps*y_;
  else
    load = 1;
  end if;

  // Power consumption
  if mode==Assumption.FixedZ_steady_state or mode==Assumption.FixedZ_dynamic then
    P = P_nominal;
  elseif mode==Assumption.VariableZ_P_input then
    P = Pow_;
  elseif mode==Assumption.VariableZ_P_inputFile then
    P = noEvent( if invertSign then -load_fromFile.y[1] else load_fromFile.y[1]);
  else
    P = P_nominal*load;
  end if;

  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics), Documentation(revisions="<html>
<ul>
<li>
October 31, 2013, by Marco Bonvini:<br/>
Model included into the Buildings library.
</li>
</ul>
</html>"));
end PartialLoad;
