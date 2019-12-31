function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 11-Mar-2018 13:29:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;
default_hiddenneuron=377;
set(handles.edit14,'String',default_hiddenneuron);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- [Browse ...] Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename pathname] = uigetfile({'*.jpg'},'File Selector');
citra_awal = strcat(pathname, filename);
InfoImage = imfinfo(citra_awal);
width = InfoImage.Width;
height = InfoImage.Height;
filesize = InfoImage.FileSize;
disp(width);
disp(height);
disp(filesize);
axes(handles.axes1);
imshow(citra_awal);
handles.citra_awal = citra_awal;
guidata(hObject, handles);

% --- [GO] Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reset(handles);
citra_awal = imread(handles.citra_awal);
axes(handles.axes1);
imshow(citra_awal);
handles.citra_awal = citra_awal;
guidata(hObject, handles);

% grayscaling & resizing
citra_gray = rgb2gray(citra_awal);
citra_gray = imresize(citra_gray, [NaN 400]); %400 columns

% median filtering
%citra_filter = medfilt2(citra_gray);
citra_filter = wiener2(citra_gray,[5 5]);

% binerisasi
citra_bnw = imbinarize(citra_filter);
%citra_bnw = imbinarize(citra_filter, 'adaptive');
%citra_bnw = imbinarize(citra_filter,'adaptive','ForegroundPolarity','dark','Sensitivity',0.7);
%citra_bnw=adaptivethreshold(citra_filter,11,0.03,1);
%citra_bnw=adaptivethreshold(citra_filter,11,0.03);

% noise removal -> closing
citra_closing = bwareaopen(citra_bnw, 100);
se = strel('disk',2);
citra_closing = imclose(citra_closing,se);

% small object removal
citra_bersih = bwareaopen(citra_closing, 470); %default = 500
axes(handles.axes7);
imshow(citra_bersih);

% clear border
citra_noborder = imclearborder(citra_bersih,4);
axes(handles.axes7);
imshow(citra_noborder);

% segmentation
%labeledImage = bwlabel(citra_bersih, 4);
labeledImage = bwlabel(citra_noborder, 4);
blobMeasurements = regionprops(labeledImage, 'all');
numberOfBlobs = size(blobMeasurements, 1);
iter=1;
start_time_test=cputime;
for k = 1 : numberOfBlobs
    	% Find the bounding box of each blob.
		thisBlobsBoundingBox = blobMeasurements(k).BoundingBox;  % Get list of pixels in current blob.
		
        % Extract out this coin into it's own image.
		
        subImage = imcrop(citra_bersih, thisBlobsBoundingBox);
        %subImage = imcrop(citra_noborder, thisBlobsBoundingBox);
        
		% Determine if it's a dime (small) or a nickel (large coin).
		if blobMeasurements(k).Area > 2200
			coinType = 'nickel';
		else
			coinType = 'dime';
		end
		% Display the image with informative caption.
        %hitung_length = imread(citra_bersih);
        [length, width] = size(subImage);
        subImage = imresize(subImage, [32 16]); %16 columns
        image_single_row = reshape(subImage ,1,[]); %convert to single row array
        hasil_klasifikasi=elm_testing(image_single_row);
        if hasil_klasifikasi==0
        	hasil_klasifikasi='0';
        elseif hasil_klasifikasi==1
            hasil_klasifikasi='1';
        elseif hasil_klasifikasi==2
            hasil_klasifikasi='2';
        elseif hasil_klasifikasi==3
            hasil_klasifikasi='3';
        elseif hasil_klasifikasi==4
            hasil_klasifikasi='4';
        elseif hasil_klasifikasi==5
            hasil_klasifikasi='5';
        elseif hasil_klasifikasi==6
            hasil_klasifikasi='6';
        elseif hasil_klasifikasi==7
            hasil_klasifikasi='7';
        elseif hasil_klasifikasi==8
            hasil_klasifikasi='8';
        elseif hasil_klasifikasi==9
            hasil_klasifikasi='9';
        elseif hasil_klasifikasi==10
            hasil_klasifikasi='A';
        elseif hasil_klasifikasi==11
            hasil_klasifikasi='B';
        elseif hasil_klasifikasi==12
            hasil_klasifikasi='C';
        elseif hasil_klasifikasi==13
            hasil_klasifikasi='D';
        elseif hasil_klasifikasi==14
            hasil_klasifikasi='E';
        elseif hasil_klasifikasi==15
            hasil_klasifikasi='F';
        elseif hasil_klasifikasi==16
            hasil_klasifikasi='G';
        elseif hasil_klasifikasi==17
            hasil_klasifikasi='H';
        elseif hasil_klasifikasi==18
            hasil_klasifikasi='I';
        elseif hasil_klasifikasi==19
            hasil_klasifikasi='J';
        elseif hasil_klasifikasi==20
            hasil_klasifikasi='K';
        elseif hasil_klasifikasi==21
            hasil_klasifikasi='L';
        elseif hasil_klasifikasi==22
            hasil_klasifikasi='M';
        elseif hasil_klasifikasi==23
            hasil_klasifikasi='N';
        elseif hasil_klasifikasi==24
            hasil_klasifikasi='O';
        elseif hasil_klasifikasi==25
            hasil_klasifikasi='P';
        elseif hasil_klasifikasi==26
            hasil_klasifikasi='Q';
        elseif hasil_klasifikasi==27
            hasil_klasifikasi='R';
        elseif hasil_klasifikasi==28
            hasil_klasifikasi='S';
        elseif hasil_klasifikasi==29
            hasil_klasifikasi='T';
        elseif hasil_klasifikasi==30
            hasil_klasifikasi='U';
        elseif hasil_klasifikasi==31
            hasil_klasifikasi='V';
        elseif hasil_klasifikasi==32
            hasil_klasifikasi='W';
        elseif hasil_klasifikasi==33
            hasil_klasifikasi='X';
        elseif hasil_klasifikasi==34
            hasil_klasifikasi='Y';
        elseif hasil_klasifikasi==35
            hasil_klasifikasi='Z';
        end
        
        if length > width && length > 50 && width > 10 %default: length > 50 && width > 10 / && length < 110
            if iter == 1
            axes(handles.axes13);
            set(handles.edit2,'String',hasil_klasifikasi);
            elseif iter == 2
            axes(handles.axes14);
            set(handles.edit3,'String',hasil_klasifikasi);
            elseif iter == 3
            axes(handles.axes15);
            set(handles.edit4,'String',hasil_klasifikasi);
            elseif iter == 4
            axes(handles.axes16);
            set(handles.edit5,'String',hasil_klasifikasi);
            elseif iter == 5
            axes(handles.axes17);
            set(handles.edit6,'String',hasil_klasifikasi);
            elseif iter == 6
            axes(handles.axes18);
            set(handles.edit7,'String',hasil_klasifikasi);
            elseif iter == 7
            axes(handles.axes19);
            set(handles.edit8,'String',hasil_klasifikasi);
            elseif iter == 8
            axes(handles.axes20);
            set(handles.edit9,'String',hasil_klasifikasi);
            elseif iter == 9
            axes(handles.axes21);
            set(handles.edit10,'String',hasil_klasifikasi);
            end
            imshow(subImage);
            iter=iter+1;
        end
end
    if get(handles.edit2,'String')==''
      char1='';
    else
      char1=get(handles.edit2,'String');
    end
    
    if get(handles.edit3,'String')==''
      char2='';
    else
      char2=get(handles.edit3,'String');
    end
    
    if get(handles.edit4,'String')==''
      char3='';
    else
      char3=get(handles.edit4,'String');
    end

    if get(handles.edit5,'String')==''
      char4='';
    else
      char4=get(handles.edit5,'String');
    end

    if get(handles.edit6,'String')==''
      char5='';
    else
      char5=get(handles.edit6,'String');
    end
    
    if get(handles.edit7,'String')==''
      char6='';
    else
      char6=get(handles.edit7,'String');
    end
    
    if get(handles.edit8,'String')==''
      char7='';
    else
      char7=get(handles.edit8,'String');
    end
    
    if get(handles.edit9,'String')==''
      char8='';
    else
      char8=get(handles.edit9,'String');
    end
    
    if get(handles.edit10,'String')==''
      char9='';
    else
      char9=get(handles.edit10,'String');
    end
hasil_akhir = strcat(char1,char2,char3,char4,char5,char6,char7,char8,char9);
end_time_test=cputime;
TestingTime=end_time_test-start_time_test;
set(handles.edit1,'String',hasil_akhir);
set(handles.edit19,'String',TestingTime);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_1=getimage(handles.axes13);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_1, Name, 'jpg');

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_2=getimage(handles.axes14);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_2, Name, 'jpg');

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_3=getimage(handles.axes15);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_3, Name, 'jpg');

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_4=getimage(handles.axes16);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_4, Name, 'jpg');

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_5=getimage(handles.axes17);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_5, Name, 'jpg');

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_6=getimage(handles.axes18);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_6, Name, 'jpg');

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_7=getimage(handles.axes19);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_7, Name, 'jpg');

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_8=getimage(handles.axes20);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_8, Name, 'jpg');

% -- Fungi persebaran piksel putih
function [f] = histogramPersebaranPikselPutih(orientasi,cit)
    [lebar, panjang]=size(cit);
    citra=double(cit);
    if strcmp(orientasi, 'horisontal')
        variabelTerikat = lebar;
        variabelBebas = panjang;
    else
        variabelTerikat = panjang;
        variabelBebas = lebar;
    end
    f(1:variabelTerikat)=0;
    for y=1:variabelTerikat
        for x=1:variabelBebas
            if strcmp(orientasi, 'horisontal')
                f = scanning_horizontally(f, citra, x, y);
            else
                f = scanning_vertically(f, citra, x, y);
            end
        end
    end
    
function f = scanning_horizontally(f, citra, x, y)
    if (citra(y, x) == 1) % 1 untuk putih
        f(y)=f(y)+1
    end
      
function f = scanning_vertically(f, citra, x, y)
    if (citra(x, y) == 1) % 1 untuk putih
        f(y)=f(y)+1
    end

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reset(handles);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
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



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ekstraksi();

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
jml_hidden_neuron = get(handles.edit14,'String');
jml_hidden_neuron = str2num(jml_hidden_neuron);
[TrainingTime,TrainingAccuracy]=elm_train(1,jml_hidden_neuron,'sig'); %fungsi aktivasi sigmoid
set(handles.edit17,'String',TrainingAccuracy);
set(handles.edit15,'String',TrainingTime);
        

function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton13.
function radiobutton13_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton13


% --- Executes on button press in radiobutton14.
function radiobutton14_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton14


function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double



% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value = get(handles.slider4,'value');
guidata(hObject,handles);
value=int16(value);
set(handles.edit14,'String',value)

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function f = reset(handles)
    axes(handles.axes1)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes7)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes13)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes14)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes15)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes16)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes17)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes18)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes19)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes20)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    axes(handles.axes21)
    cla reset;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);

    set(handles.edit1,'String','');
    set(handles.edit2,'String','');
    set(handles.edit3,'String','');
    set(handles.edit4,'String','');
    set(handles.edit5,'String','');
    set(handles.edit6,'String','');
    set(handles.edit7,'String','');
    set(handles.edit8,'String','');
    set(handles.edit9,'String','');
    set(handles.edit10,'String','');
    set(handles.edit19,'String','');
