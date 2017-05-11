function [] = creteSOFA_IIR(projectName,subjectName,fs)

    
    % Variable for FS folder name as a string
    fsFolder = int2str(round(fs/1000));
    
    Order = 24; % Order of IIR filter. 24 gives a good response
    Numpoints = 170; % Number of points measured

    OldFs = 48000;  % For changing sampling rate if required
    NewFs = 44100;

    % Note that you need to know the ITDs of the FIR based HRTFs. When the code
    % reaches this point a dialog box will be prompted to load the ITD lookup
    % table and to give it the name 'ITD_Lookup_Table'
    S = uiimport(strcat(subjectname,'_ITD_Lookup_Table.txt'));

    Az = S.ITD_Lookup_Table(:,1);
    El = S.ITD_Lookup_Table(:,2);
    ITD = S.ITD_Lookup_Table(:,3);

    %El = El+90; % Offset elevation so it's in same format as SOFA

    ObjFIR = SOFAload(strcat(subjectname,'_256order_fir_48000.sofa'));
    ObjIIR = SOFAgetConventions('SimpleFreeFieldSOS');

    ObjIIR.SourcePosition = ObjFIR.SourcePosition(1:Numpoints,:);

    ObjIIR.Data.SOS = [];
    for i = 1:Numpoints %length(ObjFIR.Data.IR)
        i

        Index1 = find(Az == ObjFIR.SourcePosition(i,1));
        Index2 = find(El == ObjFIR.SourcePosition(i,2));

        I = ismember(Index1, Index2);
        val = find(I == 1);

        ITDsamps = ITD(Index1(val))*NewFs;

        ObjIIR.Data.Delay(i,:) = [round(ITDsamps/2) -round(ITDsamps/2)];    


        for j = 1:2

            h = resample(squeeze(ObjFIR.Data.IR(i,j,:)), NewFs, OldFs);

            [y ym] = rceps(h);

            [b a] = prony(ym, Order, Order);
            [sos] = tf2sos(b,a);
    %         fvtool(squeeze(ObjFIR.Data.IR(i,j,:))',1,b,a)
    %         pause
    %         close all
            ObjIIR.Data.SOS(i,j,:) = reshape(sos',[6*Order/2 1]);  

        end
    end

    ObjIIR.GLOBAL_SOFAConventions = 'SimpleFreeFieldSOS';
    %fvtool(h(:,1),1,b,a)

    %% save the SOFA file

    ObjIIR.Data.SamplingRate = NewFs;

    Obj=SOFAsave(strcat(subjectname,'_itd_', int2str(Order), '_order_biquads_', int2str(NewFs), '.sofa'), ObjIIR, 0);
end
