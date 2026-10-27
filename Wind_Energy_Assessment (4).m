function Wind_Energy_Assessment
%% ECW26014 - Wind Energy Availability Assessment
% Interactive MATLAB simulation (software-only; no hardware required)
% Save this file as Wind_Energy_Assessment.m and press Run.

clear; clc; close all;

% Assumed turbine/model parameters (edit these for your chosen turbine)
rho = 1.225;       % Air density (kg/m^3)
Cp = 0.40;         % Power coefficient (simplified assumption)
eta = 0.90;        % Generator/electrical efficiency
cutIn = 3;         % Cut-in wind speed (m/s)
ratedSpeed = 12;   % Rated wind speed (m/s)
cutOut = 25;       % Cut-out wind speed (m/s)
ratedPower = 1000; % Rated electrical output (W)

% Initial user-adjustable values
initialWind = 8;       % m/s
initialRadius = 1.0;   % m
initialHours = 1.0;    % hours

% Create dashboard
fig = uifigure('Name','Wind Energy Availability Assessment', ...
    'Position',[100 100 1100 680], 'Color',[0.96 0.98 1.00]);

uilabel(fig,'Text','WIND ENERGY AVAILABILITY ASSESSMENT', ...
    'Position',[25 635 1050 30],'FontSize',21,'FontWeight','bold', ...
    'HorizontalAlignment','center','FontColor',[0.05 0.20 0.38]);

uilabel(fig,'Text','Move the sliders to simulate changing wind conditions.', ...
    'Position',[25 608 1050 20],'FontSize',12, ...
    'HorizontalAlignment','center','FontColor',[0.25 0.30 0.36]);

% Input panel
p = uipanel(fig,'Title','Simulation Inputs','Position',[25 355 300 235], ...
    'FontWeight','bold');

uilabel(p,'Text','Wind speed (m/s)','Position',[15 170 130 22]);
windSlider = uislider(p,'Limits',[0 30],'Value',initialWind, ...
    'Position',[15 165 260 3]);
windValue = uilabel(p,'Text',sprintf('%.1f m/s',initialWind), ...
    'Position',[15 135 260 22],'FontWeight','bold');

uilabel(p,'Text','Rotor radius (m)','Position',[15 100 130 22]);
radiusSlider = uislider(p,'Limits',[0.2 3],'Value',initialRadius, ...
    'Position',[15 95 260 3]);
radiusValue = uilabel(p,'Text',sprintf('%.2f m',initialRadius), ...
    'Position',[15 65 260 22],'FontWeight','bold');

uilabel(p,'Text','Operating time (hours)','Position',[15 32 150 22]);
hoursEdit = uieditfield(p,'numeric','Limits',[0.1 24], ...
    'Value',initialHours,'Position',[170 30 105 25]);

% KPI panel
k = uipanel(fig,'Title','Live Results','Position',[25 155 300 185], ...
    'FontWeight','bold');

uilabel(k,'Text','Available wind power','Position',[15 125 160 22]);
availableLabel = uilabel(k,'Text','-- W','Position',[175 125 105 22], ...
    'FontWeight','bold','FontColor',[0.05 0.35 0.65]);

uilabel(k,'Text','Estimated electrical power','Position',[15 90 175 22]);
electricalLabel = uilabel(k,'Text','-- W','Position',[190 90 90 22], ...
    'FontWeight','bold','FontColor',[0.05 0.45 0.25]);

uilabel(k,'Text','Estimated energy','Position',[15 55 150 22]);
energyLabel = uilabel(k,'Text','-- kWh','Position',[175 55 105 22], ...
    'FontWeight','bold','FontColor',[0.55 0.25 0.05]);

statusLabel = uilabel(k,'Text','Status: --','Position',[15 18 270 25], ...
    'FontWeight','bold','FontColor',[0.15 0.20 0.30]);

% Graphs
ax1 = uiaxes(fig,'Position',[360 355 700 235]);
title(ax1,'Electrical Power vs Wind Speed');
xlabel(ax1,'Wind speed (m/s)'); ylabel(ax1,'Electrical power (W)');
grid(ax1,'on'); hold(ax1,'on');

ax2 = uiaxes(fig,'Position',[360 75 700 235]);
title(ax2,'Available Wind Power vs Wind Speed');
xlabel(ax2,'Wind speed (m/s)'); ylabel(ax2,'Available wind power (W)');
grid(ax2,'on'); hold(ax2,'on');

% Callback wiring
windSlider.ValueChangedFcn = @(src,event) updateDashboard();
radiusSlider.ValueChangedFcn = @(src,event) updateDashboard();
hoursEdit.ValueChangedFcn = @(src,event) updateDashboard();

updateDashboard();

    function updateDashboard()
        v = windSlider.Value;
        r = radiusSlider.Value;
        hours = hoursEdit.Value;
        A = pi*r^2;

        % Power available in the wind (before turbine/generator losses)
        vCurve = linspace(0,30,301);
        availableCurve = 0.5*rho*A.*vCurve.^3;

        % Simplified turbine electrical power curve:
        % zero below cut-in and at/above cut-out; capped at rated output.
        rawPower = 0.5*rho*A.*vCurve.^3.*Cp.*eta;
        electricalCurve = min(rawPower,ratedPower);
        electricalCurve(vCurve < cutIn | vCurve >= cutOut) = 0;

        availableNow = 0.5*rho*A*v^3;
        electricalNow = 0;
        if v >= cutIn && v < cutOut
            electricalNow = min(0.5*rho*A*v^3*Cp*eta,ratedPower);
        end
        energyKWh = electricalNow*hours/1000;

        windValue.Text = sprintf('%.1f m/s',v);
        radiusValue.Text = sprintf('%.2f m',r);
        availableLabel.Text = sprintf('%.1f W',availableNow);
        electricalLabel.Text = sprintf('%.1f W',electricalNow);
        energyLabel.Text = sprintf('%.4f kWh',energyKWh);

        if v < cutIn
            statusLabel.Text = sprintf('Status: Below cut-in (< %.0f m/s)',cutIn);
            statusLabel.FontColor = [0.65 0.20 0.15];
        elseif v >= cutOut
            statusLabel.Text = sprintf('Status: Shut down (>= %.0f m/s)',cutOut);
            statusLabel.FontColor = [0.65 0.20 0.15];
        elseif v >= ratedSpeed
            statusLabel.Text = 'Status: Rated-output region';
            statusLabel.FontColor = [0.05 0.45 0.25];
        else
            statusLabel.Text = 'Status: Generating power';
            statusLabel.FontColor = [0.05 0.45 0.25];
        end

        cla(ax1);
        plot(ax1,vCurve,electricalCurve,'LineWidth',2,'Color',[0.05 0.40 0.75]);
        hold(ax1,'on');
        plot(ax1,v,electricalNow,'o','MarkerSize',9,'MarkerFaceColor',[0.90 0.25 0.15], ...
            'MarkerEdgeColor',[0.90 0.25 0.15]);
        xline(ax1,cutIn,'--','Cut-in','LabelVerticalAlignment','bottom');
        xline(ax1,ratedSpeed,'--','Rated speed','LabelVerticalAlignment','bottom');
        xline(ax1,cutOut,'--','Cut-out','LabelVerticalAlignment','bottom');
        ylim(ax1,[0 max(ratedPower*1.12,max(electricalCurve)*1.12+1)]);
        xlim(ax1,[0 30]); grid(ax1,'on');

        cla(ax2);
        plot(ax2,vCurve,availableCurve,'LineWidth',2,'Color',[0.10 0.60 0.35]);
        hold(ax2,'on');
        plot(ax2,v,availableNow,'o','MarkerSize',9,'MarkerFaceColor',[0.90 0.25 0.15], ...
            'MarkerEdgeColor',[0.90 0.25 0.15]);
        xlim(ax2,[0 30]); grid(ax2,'on');

        drawnow;
    end
end % Main function
