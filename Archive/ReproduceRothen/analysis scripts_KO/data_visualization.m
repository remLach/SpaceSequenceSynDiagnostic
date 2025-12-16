clear

cd("/Users/remylachelin/Documents/SpaceSequenceSynDiagnostic/SpaceSequenceSynDiagnostic/ReproduceRothen/analysis scripts_KO") % RL 2025

fileName ='example_data.xls';   %enter current file name
a = xlsread(fileName);
[num, txt] = xlsread(fileName);

% b = a(:,9);
% c = a(:,10);
% d = a(:,5);
b = a(:,3);
c = a(:,4);
% d = a(:,5);


fail1='Program aborted. Participant number not entered'; 
prompt = {'Enter participant number:'};
dlg_title ='New Participant'; 
num_lines = 1;
def = {'0'};
answer = inputdlg(prompt,dlg_title,num_lines,def);%presents box to enter data into
switch isempty(answer)
    case 1 
        error(fail1)
    case 0
        thissub=(answer{1});
end


for  k = 1:3:163          %generates triangle for every single inducer
                          %for files without alphabet as inducer change    
    figure(1+k);          %to k = 1:3:87

    t1 = [b(0+k),c(0+k)];
    t2 = [b(1+k),c(1+k)];
    t3 = [b(2+k),c(2+k)];

        x = [t1(1) t2(1) t3(1)];
        y = [t1(2) t2(2) t3(2)];

        fill(x,y,'blue');



title(txt(1+k,2));


end 



for  k = 1:3:163       %generates an overall picture summary; for files without alphabet as inducer, change to k=1:3:87                     
      
    figure(1);
     
    t1 = [b(0+k),c(0+k)];
    t2 = [b(1+k),c(1+k)];
    t3 = [b(2+k),c(2+k)];

        x = [t1(1) t2(1) t3(1)];
        y = [t1(2) t2(2) t3(2)];
        
       hold on; 
       fill(x,y,1+k);
       text(min(x),max(y),txt(1+k,2)); % txt(1+k,5)
       
       
title(['Consistency Summary Subject' thissub]);
axis([0 1100 0 800]);
   
end

saveas(gcf,[thissub '_SummaryAll' ], 'jpg');
hold off;




for  k = 1:3:30 %generates picture summary for days
      
    figure(2);
     
    t1 = [b(0+k),c(0+k)];
    t2 = [b(1+k),c(1+k)];
    t3 = [b(2+k),c(2+k)];

        x = [t1(1) t2(1) t3(1)];
        y = [t1(2) t2(2) t3(2)];
        
       hold on; 
       fill(x,y,1+k);
       text(min(x),max(y),txt(1+k,5)); 
       
       
title(['Summary Numbers Subject' thissub] );
axis([0 1100 0 800]);


   
end

saveas(gcf, [thissub '_Summary Numbers'],'jpg');
hold off;




for  k = 31:3:51 %generates picture summary for days
      
   figure(3);
   
    t1 = [b(0+k),c(0+k)];
    t2 = [b(1+k),c(1+k)];
    t3 = [b(2+k),c(2+k)];

        x = [t1(1) t2(1) t3(1)];
        y = [t1(2) t2(2) t3(2)];
        
       hold on; 
       fill(x,y,1+k);
       text(min(x),max(y),txt(1+k,5)); 
       
       
title(['Summary Days Subject' thissub]);
axis([0 1100 0 800]);

   
end 

saveas(gcf, [thissub '_Summary Days'],'jpg');
hold off;

for  k = 52:3:85    % generates picture summary for months
      
   figure(4);
     
    t1 = [b(0+k),c(0+k)];
    t2 = [b(1+k),c(1+k)];
    t3 = [b(2+k),c(2+k)];

        x = [t1(1) t2(1) t3(1)];
        y = [t1(2) t2(2) t3(2)];
        
       hold on; 
       fill(x,y,1+k);
       text(min(x),max(y),txt(1+k,5)); 
       
       
title(['Summary Months Subject' thissub]);
axis([0 1100 0 800]);


   
end

saveas(gcf, [thissub '_Summary Months'],'jpg');
hold off;




% for  k = 88:3:163              %generates picture summary for alphabet; comment out (until line 179) for files without alphabet 
% 
%     figure(5);
% 
%     t1 = [b(0+k),c(0+k)];
%     t2 = [b(1+k),c(1+k)];
%     t3 = [b(2+k),c(2+k)];
% 
%         x = [t1(1) t2(1) t3(1)];
%         y = [t1(2) t2(2) t3(2)];
% 
%        hold on; 
%        fill(x,y,1+k);
%        text(min(x),max(y),txt(1+k,5)); 
% 
% 
% title(['Summary Alphabet Subject' thissub]);
% axis([0 1100 0 800]);
% 
% 
% end 
% 
% saveas(gcf, [thissub '_Summary Alphabet'],'jpg');
% 
% 
% 
