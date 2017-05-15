function [] = FIRtoIIR(projectName,subjectName,fileLength,fs,bit,Order,compression)
    disp('---Running FIRtoIIR---');
    
    % Variable for FS folder name as a string
    fsFolder = int2str(round(fs/1000));
    
    Numpoints = 50; % Number of points measured

    OldFs = 48000;  % For changing sampling rate if required
    NewFs = 44100;

    % Note that you need to know the ITDs of the FIR based HRTFs. When the code
    % reaches this point a dialog box will be prompted to load the ITD lookup
    % table and to give it the name 'ITD_Lookup_Table'
    
    % Read IDT Lookup Table
    disp(strcat('Audio/',projectName,'/SOFAFiles/lookUpTables/',subjectName,'_ITD_Lookup_Table.txt'));
    fid = fopen(strcat('Audio/LewisTestFolder/SOFAFiles/lookUpTables/TestSubject_ITD_Lookup_Table.txt'),'r');
    S = textscan(fid,'%d%d%f');
    fclose(fid);

    Az = S(:,1);
    El = S(:,2);
    ITD = S(:,3);
    disp(ITD)
    Az = cell2mat(Az);
    El = cell2mat(El);
    ITD = cell2mat(ITD);
    
    for k = 1:length(Az)
        disp(sprintf('Az(%i): El(%i): ITD(%f): ',Az(k),El(k),ITD(k)));
    end
        

    %El = El+90; % Offset elevation so it's in same format as SOFA

    ObjFIR = SOFAload(strcat('Audio/',projectName,'/SOFAFiles/SOFA_FFEQ/',subjectName,'/',subjectName,'_',int2str(fileLength),'order_fir_',fsFolder,'k_',int2str(bit),'bit_.sofa'));
    ObjIIR = SOFAgetConventions('SimpleFreeFieldSOS');

    ObjIIR.SourcePosition = ObjFIR.SourcePosition(1:Numpoints,:);
    
    ObjIIR.Data.SOS = [];
    for i = 1:Numpoints %length(ObjFIR.Data.IR)

        Index1 = find(Az == ObjFIR.SourcePosition(i,1));
        Index2 = find(El == ObjFIR.SourcePosition(i,2));

        I = ismember(Index1, Index2);
        val = find(I == 1);

        ITDsamps = ITD(Index1(val))*fs;

        ObjIIR.Data.Delay(i,:) = [round(ITDsamps/2) -round(ITDsamps/2)];    

        ObjIIR.Data.SamplingRate = fs;

        % If recorded in 48 produce 44.1k version too
            for j = 1:2
                
                h = resample(squeeze(ObjFIR.Data.IR(i,j,:)), 44100, 48000);
                
                %disp(sprintf('a: %d b: %d',ObjFIR.Data.IR(i,j,:),h));
                
                [y ym] = rceps(h);

                [b a] = prony(ym, Order, Order);
                [sos] = tf2sos(b,a);
        %         fvtool(squeeze(ObjFIR.Data.IR(i,j,:))',1,b,a)
        %         pause
        %         close all
                ObjIIR.Data.SOS(i,j,:) = reshape(sos',[6*Order/2 1]);  

            end
        end

        outputFileName = strcat('Audio/',projectName,'/SOFAFiles/SOFA_FFEQ/',subjectName,'/',subjectName,'_',int2str(fileLength),'order_biquads_',fsFolder,'k_',int2str(bit),'_bit_.sofa');
        disp('FIRtoIIR: Saving SOFA File...');
        disp(outputFileName);
        Obj=SOFAsave(outputFileName, ObjIIR, compression);
        %Obj=SOFAsave(strcat(subjectname,'_itd_', int2str(Order), '_order_biquads_', int2str(NewFs), '.sofa'), ObjIIR, 0);
        disp('FIRtoIIR: Saved');

    ObjIIR.GLOBAL_SOFAConventions = 'SimpleFreeFieldSOS';
    %fvtool(h(:,1),1,b,a)

end
