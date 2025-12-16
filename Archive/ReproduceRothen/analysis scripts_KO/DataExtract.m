% From https://www.sussex.ac.uk/synaesthesia/documents/matlab-script-for-analysing-and-plotting-sss.docx
[M,N]=xlsread('rawdata.xlsx'); % M extracts number array and N extracts text array
 
X_res = M(:,4);
Y_res = M(:,5);
participant = M(:,2);
block = M(:,7); 
RT = M(:,9); % RTs in 11th column
stimulus = M(:,11); % stimulus number (1-29) in 11th column
x = M(:,12); % x-values in 12th column
y = M(:,13); % y-values in 13th column
answer = [];
label = {'0','1','2','3','4','5','6','7','8','9','Mon', 'Tues', 'Weds', 'Thur', 'Fri', 'Sat', 'Sun','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'};
 
for subject_number = 1 : size(x,1)/87 % calculates how many participants in file
 
for a = (1+87*(subject_number-1)) : (87+87*(subject_number-1))  %changes the array from a random order to be arranged from 1 to 29
    x_sorted((stimulus(a)-1)*3+block(a))=x(a);    
    y_sorted((stimulus(a)-1)*3+block(a))=y(a);
end %a
 
number_area = 0;
for count = 1 : 10  %numbers have stimulus values of 1 to 10
    Ax = x_sorted(count*3 - 2);
    Ay = y_sorted(count*3 - 2);
    Bx = x_sorted(count*3 - 1);
    By = y_sorted(count*3 - 1);
    Cx = x_sorted(count*3);
    Cy = y_sorted(count*3);
    number_area = number_area + abs(Ax*(By-Cy) + Bx*(Cy-Ay) + Cx*(Ay-By))/2;
    
    figure(subject_number);
    shape_x = [Ax Bx Cx];
    shape_y = [Ay By Cy];
        
    hold on; 
    fill(shape_x,shape_y,count);
    text(min(shape_x),max(shape_y),label(count)); 
    grid;
    axis([0 Y_res(a) 0 X_res(a)]);    
end %a
figure_title = strcat(num2str(participant(a)),'_Summary_Numbers');
saveas(gcf, figure_title, 'jpg');
hold off;
close;
 
day_area = 0;
for count = 11 : 17  %numbers have stimulus values of 11 to 17
    Ax = x_sorted(count*3 - 2);
    Ay = y_sorted(count*3 - 2);
    Bx = x_sorted(count*3 - 1);
    By = y_sorted(count*3 - 1);
    Cx = x_sorted(count*3);
    Cy = y_sorted(count*3);
    day_area = day_area + abs(Ax*(By-Cy) + Bx*(Cy-Ay) + Cx*(Ay-By))/2;
    figure(subject_number);
    shape_x = [Ax Bx Cx];
    shape_y = [Ay By Cy];
        
    hold on; 
    fill(shape_x,shape_y,count);
    text(min(shape_x),max(shape_y),label(count)); 
    grid;
    axis([0 Y_res(a) 0 X_res(a)]);    
 
end %a
figure_title = strcat(num2str(participant(a)),'_Summary_Days');
saveas(gcf, figure_title, 'jpg');
hold off;
close;
 
month_area = 0;
for count = 18 : 29  %numbers have stimulus values of 11 to 17
    Ax = x_sorted(count*3 - 2);
    Ay = y_sorted(count*3 - 2);
    Bx = x_sorted(count*3 - 1);
    By = y_sorted(count*3 - 1);
    Cx = x_sorted(count*3);
    Cy = y_sorted(count*3);
    month_area = month_area + abs(Ax*(By-Cy) + Bx*(Cy-Ay) + Cx*(Ay-By))/2;
    
figure(subject_number);
    shape_x = [Ax Bx Cx];
    shape_y = [Ay By Cy];
        
    hold on; 
    fill(shape_x,shape_y,count);
    text(min(shape_x),max(shape_y),label(count)); 
    grid;
    axis([0 Y_res(a) 0 X_res(a)]);    
        
end %a
figure_title = strcat(num2str(participant(a)),'_Summary_Months');
saveas(gcf, figure_title, 'jpg');
hold off;
close;
 
total_area = (number_area + month_area + day_area)/29;
number_area = number_area /10; % calculate an average
month_area = month_area /12; % calculate an average
day_area = day_area /7; % calculate an average
 
answer = [answer; participant(a), X_res(a), Y_res(a), number_area, day_area, month_area, total_area];
 
end % subject_number
% creates an excel file with these columns 'Participant', 'X-resolution', 'Y-resolution', 'numbers', 'days', 'months', 'total'; answer]
xlswrite('SSS_consistency', answer);

