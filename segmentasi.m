function varargout = segmentasi(varargin)
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

% Last Modified by GUIDE v2.5 12-Jan-2018 23:09:54

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
citra_awal = imread(handles.citra_awal);

% grayscaling & resizing
citra_gray = rgb2gray(citra_awal);
citra_gray = imresize(citra_gray, [NaN 400]); %400 columns
axes(handles.axes2);
imshow(citra_gray);


% median filtering
citra_filter = medfilt2(citra_gray);
axes(handles.axes3);
imshow(citra_filter);

% binerisasi
citra_bnw = imbinarize(citra_filter);
%citra_bnw = imbinarize(citra_filter, 'adaptive');
%citra_bnw = imbinarize(citra_filter,'adaptive','ForegroundPolarity','dark','Sensitivity',0.7);
%citra_bnw=adaptivethreshold(citra_filter,11,0.03,1);
%citra_bnw=adaptivethreshold(citra_filter,11,0.03);
axes(handles.axes4);
imshow(citra_bnw);

% noise removal -> closing
citra_closing = bwareaopen(citra_bnw, 100);
se = strel('disk',2);
citra_closing = imclose(citra_closing,se);
axes(handles.axes5);
imshow(citra_closing);

% small object removal
citra_bersih = bwareaopen(citra_closing, 498); %default = 500
citra_bersih = imclearborder(citra_bersih,4);
axes(handles.axes6);
imshow(citra_bersih);

% clear border
%citra_noborder = imclearborder(citra_bersih,4);
%axes(handles.axes7);
%imshow(citra_noborder);

%{
% cropping batas kanan dan kiri frame
[f]=histogramPersebaranPikselPutih('vertikal', citra_bersih);
[lebar, panjang] = size(citra_bersih);
%mencari frekuensi tertinggi di bagian kiri
[frekuensitertinggikiri, bataskiri] = max(f(1:round(panjang/2)));
%hitung panjang baru
panjangbaru = panjang-(bataskiri*2);
%cropping
hasil_crop1=imcrop(citra_bersih,[bataskiri 0 panjangbaru lebar]);
axes(handles.axes7);
imshow(hasil_crop1);


% cropping batas atas bawah plat
[f]=histogramPersebaranPikselPutih('horisontal', hasil_crop1);
[lebar, panjang] = size(hasil_crop1);
%ubah pixel baris ke y yg frekuensi piksel putihnya <=1/7*panjang jd nol
%semua
for (i=1:lebar)
    if f(i) <= ((1/7)*panjang)
        for (j=1:panjang)
            hasil_crop1(i,j)=0;
        end
        f(i)=0;
    end
end
%cari frekuensi tertinggi atas
[frekuensitertinggiatas, batasatas] = max(f(1:round(lebar/2)));
while (f(batasatas)~=0)
    batasatas=batasatas+1;
end
while (f(batasatas)==0)
    batasatas=batasatas+1;
end
%mencari batasbawah / lebarbaru, pixel ke-lebar
lebar = batasatas;
while (f(lebar)~=0 || (lebar-batasatas) < 10)
    lebar=lebar+1;
end
lebarbaru = lebar - batasatas;
%cropping
hasil_crop2=imcrop(hasil_crop1, [0 batasatas panjang lebarbaru]);
axes(handles.axes11);
imshow(hasil_crop2);

%cropping batas kanan kiri pelat
[lebar, panjang] = size(hasil_crop2);
[f]=histogramPersebaranPikselPutih('vertikal', hasil_crop2);
%cari batas kiri
bataskiri=1;
while (f(bataskiri)~=0)
    bataskiri=bataskiri+1;
end
while (f(bataskiri)==0)
    bataskiri=bataskiri+1;
end
%cari batas kanan
bataskanan=panjang;
while (f(bataskanan)~=0)
    bataskanan=bataskanan+1;
end
while (f(bataskanan)==0)
    bataskanan=bataskanan+1;
end
panjangbaru=bataskanan-1;
%cropping
hasil_crop3=imcrop(hasil_crop2, [bataskiri 0 panjangbaru lebar]);
axes(handles.axes9);
imshow(hasil_crop3);
%}

% segmentation
labeledImage = bwlabel(citra_bersih, 4);
%labeledImage = bwlabel(citra_noborder, 4);
blobMeasurements = regionprops(labeledImage, 'all');
numberOfBlobs = size(blobMeasurements, 1);
iter=1;
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
        
        %{
        %thinning
        changing = 1;
        [rows, columns] = size(subImage);
        BW_Thinned = subImage;
        BW_Del = ones(rows, columns);
        while changing
            % BW_Del = ones(rows, columns);
            changing = 0;
            % Setp 1
            for i=2:rows-1
                for j = 2:columns-1
                    P = [BW_Thinned(i,j) BW_Thinned(i-1,j) BW_Thinned(i-1,j+1) BW_Thinned(i,j+1) BW_Thinned(i+1,j+1) BW_Thinned(i+1,j) BW_Thinned(i+1,j-1) BW_Thinned(i,j-1) BW_Thinned(i-1,j-1) BW_Thinned(i-1,j)]; % P1, P2, P3, ... , P8, P9, P2
                    if (BW_Thinned(i,j) == 1 &&  sum(P(2:end-1))<=6 && sum(P(2:end-1)) >=2 && P(2)*P(4)*P(6)==0 && P(4)*P(6)*P(8)==0)   % conditions
                        % No. of 0,1 patterns (transitions from 0 to 1) in the ordered sequence
                        A = 0;
                        for k = 2:size(P,2)-1
                            if P(k) == 0 && P(k+1)==1
                                A = A+1;
                            end
                        end
                        if (A==1)
                            BW_Del(i,j)=0;
                            changing = 1;
                        end
                    end
                end
            end
            BW_Thinned = BW_Thinned.*BW_Del;  % the deletion must after all the pixels have been visited
            % Step 2 
            for i=2:rows-1
                for j = 2:columns-1
                    P = [BW_Thinned(i,j) BW_Thinned(i-1,j) BW_Thinned(i-1,j+1) BW_Thinned(i,j+1) BW_Thinned(i+1,j+1) BW_Thinned(i+1,j) BW_Thinned(i+1,j-1) BW_Thinned(i,j-1) BW_Thinned(i-1,j-1) BW_Thinned(i-1,j)];
                    if (BW_Thinned(i,j) == 1 && sum(P(2:end-1))<=6 && sum(P(2:end-1)) >=2 && P(2)*P(4)*P(8)==0 && P(2)*P(6)*P(8)==0)   % conditions
                        A = 0;
                        for k = 2:size(P,2)-1
                            if P(k) == 0 && P(k+1)==1
                                A = A+1;
                            end
                        end
                        if (A==1)
                            BW_Del(i,j)=0;
                            changing = 1;
                        end
                    end
                end
            end
            BW_Thinned = BW_Thinned.*BW_Del;
        end
        %}
        
        %[length_asal, width_asal] = size(hitung_length);
        %if length >= length_asal / 2
        if length > width && length > 50 && width > 10 %default: length > 50 && width > 10 / && length < 110
            if iter == 1
            axes(handles.axes13);
            elseif iter == 2
            axes(handles.axes14);
            elseif iter == 3
            axes(handles.axes15);
            elseif iter == 4
            axes(handles.axes16);
            elseif iter == 5
            axes(handles.axes17);
            elseif iter == 6
            axes(handles.axes18);
            elseif iter == 7
            axes(handles.axes19);
            elseif iter == 8
            axes(handles.axes20);
            elseif iter == 9
            axes(handles.axes21);
            end
            subImage = imresize(subImage, [32 16]); %16 columns
            imshow(subImage);
            iter=iter+1;
        end
        %end
end

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
%{
cla(handles.axes1,'reset');
cla(handles.axes2,'reset');
cla(handles.axes3,'reset');
cla(handles.axes4,'reset');
cla(handles.axes5,'reset');
cla(handles.axes6,'reset');
cla(handles.axes7,'reset');
cla(handles.axes13,'reset');
cla(handles.axes14,'reset');
cla(handles.axes15,'reset');
cla(handles.axes16,'reset');
cla(handles.axes17,'reset');
cla(handles.axes18,'reset');
cla(handles.axes19,'reset');
cla(handles.axes20,'reset');
%}
axes(handles.axes1)
cla reset;
set(gca,'XTick',[]);
set(gca,'YTick',[]);

axes(handles.axes2)
cla reset;
set(gca,'XTick',[]);
set(gca,'YTick',[]);

axes(handles.axes3)
cla reset;
set(gca,'XTick',[]);
set(gca,'YTick',[]);

axes(handles.axes4)
cla reset;
set(gca,'XTick',[]);
set(gca,'YTick',[]);

axes(handles.axes5)
cla reset;
set(gca,'XTick',[]);
set(gca,'YTick',[]);

axes(handles.axes6)
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

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
segmen_9=getimage(handles.axes21);
[FileName, PathName] = uiputfile('*.jpg', 'Save As');
Name = fullfile(PathName, FileName);
imwrite(segmen_9, Name, 'jpg');
