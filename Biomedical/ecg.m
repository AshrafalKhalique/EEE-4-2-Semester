function varargout = ecg(varargin)
% ECG MATLAB code for ecg.fig
%      ECG, by itself, creates a new ECG or raises the existing
%      singleton*.
%
%      H = ECG returns the handle to a new ECG or the handle to
%      the existing singleton*.
%
%      ECG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ECG.M with the given input arguments.
%
%      ECG('Property','Value',...) creates a new ECG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ecg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ecg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ecg

% Last Modified by GUIDE v2.5 21-Jan-2024 18:46:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ecg_OpeningFcn, ...
                   'gui_OutputFcn',  @ecg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ecg is made visible.
function ecg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ecg (see VARARGIN)

% Choose default command line output for ecg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ecg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ecg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ecgsig.
function ecgsig_Callback(hObject, eventdata, handles)
% hObject    handle to ecgsig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fullfile = dlmread('ECG_Signal.tsv');  %Load ECG signal during walking
Fs = 250; %The data are sampled at 250Hz

ecgsig = fullfile(:,2);  %reading ecg signal
samples = 1:length(ecgsig);  %No. of samples
tx = samples./Fs;  %Getting time vector
f = 1./tx; % frequency of ecg
%_______________________________
set(handles.listbox1,'String',ecgsig);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_ecg.
function plot_ecg_Callback(hObject, eventdata, handles)
% hObject    handle to plot_ecg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ecgsig = str2num(get(handles.listbox1,'String'));
Fs = 250; %The data are sampled at 250Hz
samples = 1:length(ecgsig);  %No. of samples
tx = samples./Fs;  %Getting time vector
f = 1./tx; % frequency of ecg
axes(handles.axes1);
plot(tx,ecgsig);
title('Original Lead II ECG Signal')
legend('Original ECG');
xlabel('Time (sec)')
ylabel('Voltage (volt)')
grid on


% --- Executes on button press in baseline_drift.
function baseline_drift_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_drift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ecgsig = str2num(get(handles.listbox1,'String'));
Fs = 250; %The data are sampled at 250Hz
samples = 1:length(ecgsig);  %No. of samples
tx = samples./Fs;  %Getting time vector
f = 1./tx; % frequency of ecg

%____________code for removal of baseline noise________________________
for i = 1:1:length(ecgsig)
if i == 1
m(i) = ecgsig(i+1)-ecgsig(i);
end
if i>1
m(i) = ecgsig(i-1)-ecgsig(i);
end
end
denoised = m;
wp=20; ws=60; rp=0.5; rs=25; %Design a Butterworth filter of order 9 for smoothing noise 
[N, Wn] = buttord(wp/(Fs/2), ws/(Fs/2), rp, rs);
[b, a]=butter(N, Wn);
yy=filter(b,a,denoised);
axes(handles.axes1);
plot(tx, yy);
title('Baseline noise removed ECG')
legend('Baseline noise removed ECG');
xlabel('Time (sec)')
ylabel('Voltage (volt)')
grid on


% --- Executes on button press in r_peak.
function r_peak_Callback(hObject, eventdata, handles)
% hObject    handle to r_peak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ecgsig = str2num(get(handles.listbox1,'String'));
Fs = 250; %The data are sampled at 250Hz
samples = 1:length(ecgsig);  %No. of samples
tx = samples./Fs;  %Getting time vector
f = 1./tx; % frequency of ecg

for i = 1:1:length(ecgsig)
if i == 1
m(i) = ecgsig(i+1)-ecgsig(i);
end
if i>1
m(i) = ecgsig(i-1)-ecgsig(i);
end
end
base_remove_signal = m;
for i = 1:1:length(base_remove_signal)
    if base_remove_signal(i)>=0.0005
        n(i)=base_remove_signal(i);
    end
end
r_peak=n;
plot(r_peak);
title('R Peak Detected Signal')
legend('R Peak Detected Signal');
xlabel('Time (sec)')
ylabel('Voltage (volt)')
grid on


% --- Executes on button press in parameters.
function parameters_Callback(hObject, eventdata, handles)
% hObject    handle to parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ecgsig = str2num(get(handles.listbox1,'String'));
Fs = 250; %The data are sampled at 250Hz
samples = length(ecgsig);  %No. of samples
tx = samples/Fs;  %Getting time vector
f = 1/tx; % frequency of ecg

for i = 1:1:length(ecgsig)
if i == 1
m(i) = ecgsig(i+1)-ecgsig(i);
end
if i>1
m(i) = ecgsig(i-1)-ecgsig(i);
end
end
base_remove_signal = m;
for i = 1:1:length(base_remove_signal)
    if base_remove_signal(i)>=0.0005
        n(i)=base_remove_signal(i);
    end
end
r_peak=n;

[pks, locs] = findpeaks(r_peak, 'MinPeakHeight', 0.0005, ...  % Adjust parameters as needed
                          'MinPeakDistance', 100, ...
                          'MinPeakProminence', 0.2);

rr_intervals = diff(locs);  % Calculate RR intervals
rr_seconds=rr_intervals/Fs;

hr_bpm = 60.0 ./ rr_seconds;

set(handles.time,'String',tx);
set(handles.rr_interval,'String',rr_seconds);
set(handles.heart_rate,'String',hr_bpm);


function time_Callback(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time as text
%        str2double(get(hObject,'String')) returns contents of time as a double


% --- Executes during object creation, after setting all properties.
function time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rr_interval_Callback(hObject, eventdata, handles)
% hObject    handle to rr_interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rr_interval as text
%        str2double(get(hObject,'String')) returns contents of rr_interval as a double


% --- Executes during object creation, after setting all properties.
function rr_interval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rr_interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function heart_rate_Callback(hObject, eventdata, handles)
% hObject    handle to heart_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of heart_rate as text
%        str2double(get(hObject,'String')) returns contents of heart_rate as a double


% --- Executes during object creation, after setting all properties.
function heart_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heart_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
