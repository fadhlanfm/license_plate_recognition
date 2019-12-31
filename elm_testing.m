function [hasil_deteksi] = elm_testing(data)
    CLASSIFIER=1;

    %%%%%%%%%%% Load testing dataset
    %test_data = cell2mat(data);
    TV.P = data(:,1:512)';
    %   Release raw testing data array
    clear test_data;                                    
    NumberofTestingData=size(TV.P,2);
    
    load elm_model.mat
    %%%%%%%%%%% Calculate the output of testing input
    tempH_test = InputWeight*TV.P;
    %   Release input of testing data             
    clear TV.P;             
    ind=ones(1,NumberofTestingData);
    %   Extend the bias matrix BiasofHiddenNeurons to match the demention of H
    BiasMatrix = BiasofHiddenNeurons(:,ind);
    tempH_test=tempH_test + BiasMatrix;
    switch lower(ActivationFunction)
        case {'sig','sigmoid'}
                %%%%%%%% Sigmoid 
                H_test = 1 ./ (1 + exp(-tempH_test));
        case {'sin','sine'}
                %%%%%%%% Sine
                H_test = sin(tempH_test);        
        case {'hardlim'}
                %%%%%%%% Hard Limit
                H_test = hardlim(tempH_test);        
        %%%%%%%% More activation functions can be added here        
    end
    
    %   TY: the actual output of the testing data
    TY=(H_test' * OutputWeight)';
    [x,label_index_actual] = max(TY);
    hasil_deteksi = label(label_index_actual);
end