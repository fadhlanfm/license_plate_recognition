function [data_train_9] = ekstraksi()
    cd 0;
    str='.jpg';
    dataset=[];
    f=0; %indeks folder
    c=0; %indeks class
    %menghitung jumlah image dalam folder
    currentFolder = pwd;
    image_di_folder=dir([currentFolder '/*.jpg']);
    jumlah_image=size(image_di_folder,1);
    hitung_folder = 1;

    %bukan kebaca jumlah image di folder yg skrg malah sebelumnya

    while (hitung_folder ~= 37)
    for i=1:jumlah_image
        %menghitung jumlah image dalam folder
        
        if i==9
            continue
        end %untuk menskip citra
        %i=9; %manual buat data test, for dihilangkan
        filename=strcat(num2str(i),str);
        image_char=imread(filename);
        image_char = im2bw(image_char);
        image_single_row = reshape(image_char ,1,[]); %convert to single row array
        image_single_row = [c image_single_row]; %insert class
        k = 1;
        dataset = [image_single_row(1:k,:); dataset; image_single_row(k+1:end,:)]; %insert image_single_row below A
        close all;
        figure;
        imshow(image_char,[]);
    end
    cd ..
    [f, c, jumlah_image]=iter_folder(f);
    %folder=f;
    hitung_folder=hitung_folder+1;
    end
    data_train_9=dataset;
    save('data_train_9','data_train_9');
end

function [f, c, jumlah_image] = iter_folder(x)
        if x==0
            f=1;
            c=1;
            cd 1
        elseif x==1
            f=2;
            c=2;
            cd 2
        elseif x==2
            f=3;
            c=3;
            cd 3
        elseif x==3
            f=4;
            c=4;
            cd 4
        elseif x==4
            f=5;
            c=5;
            cd 5
        elseif x==5
            f=6;
            c=6;
            cd 6;
        elseif x==6
            f=7;
            c=7;
            cd 7;
        elseif x==7
            f=8;
            c=8;
            cd 8;
        elseif x==8
            f=9;
            c=9;
            cd 9;
        elseif x==9
            f=10;
            c=10;
            cd A;
        elseif x==10
            f=11;
            c=11;
            cd B;
        elseif x==11
            f=12;
            c=12;
            cd C;
        elseif x==12
            f=13;
            c=13;
            cd D;
        elseif x==13
            f=14;
            c=14;
            cd E;
        elseif x==14
            f=15;
            c=15;
            cd F;
        elseif x==15
            f=16;
            c=16;
            cd G;
        elseif x==16
            f=17;
            c=17;
            cd H;
        elseif x==17
            f=18;
            c=18;
            cd I;
        elseif x==18
            f=19;
            c=19;
            cd J;
        elseif x==19
            f=20;
            c=20;
            cd K;
        elseif x==20
            f=21;
            c=21;
            cd L;
        elseif x==21
            f=22;
            c=22;
            cd M;
        elseif x==22
            f=23;
            c=23;
            cd N;
        elseif x==23
            f=24;
            c=24;
            cd O;
        elseif x==24
            f=25;
            c=25;
            cd P;
        elseif x==25
            f=26;
            c=26;
            cd Q;
        elseif x==26
            f=27;
            c=27;
            cd R;
        elseif x==27
            f=28;
            c=28;
            cd S;
        elseif x==28
            f=29;
            c=29;
            cd T;
        elseif x==29
            f=30;
            c=30;
            cd U;
        elseif x==30
            f=31;
            c=31;
            cd V;
        elseif x==31
            f=32;
            c=32;
            cd W;
        elseif x==32
            f=33;
            c=33;
            cd X;
        elseif x==33
            f=34;
            c=34;
            cd Y;
        elseif x==34
            f=35;
            c=35;
            cd Z;
        else
            f=0;
            c=0;
        end
    currentFolder = pwd;
    image_di_folder=dir([currentFolder '/*.jpg']);
    jumlah_image=size(image_di_folder,1);
end
%save as A di workspace (filetype: .m)