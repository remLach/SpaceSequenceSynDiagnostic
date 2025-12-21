# Thi is the excel formula!
# =H2+Y2+Z2+AA2+AB2+(6-AC2)+(6-AD2)+(6-AE2)+(6-AF2)
# ds_Q$QuestScore_repli <- ds_Q[,2] +  
#   rowSums(ds_Q[,19:22]) +
#   rowSums(6 - ds_Q[,23:26])

ds_Q$QuestScore_repli <- ds_Q[,8] +  
  rowSums(ds_Q[,25:28]) +
  rowSums(6 - ds_Q[,29:32])

plot(ds_Q$QuestScore_repli,ds_Q$`questionnaire score`)
sum(abs(ds_Q$QuestScore_repli - ds_Q$`questionnaire score`), na.rm = TRUE)
# Ok so this is how Ward has computed the questionnaire score!
# But... It's incorrect!

# That would be my way of encoding the questionnaire I guess:
# Smaller values -> synesthetes
# Range: 10 (Syn) to 61 (Ctl)
ds_Q$QuestScoreRL <- ds_Q[,2] + # Q1  "routinely think about sequences in space" 1 [1 = yes, 5 = no]
  rowSums(1 - ds_Q[,3:10]) +    # Q2 [rev code]. If present month,num, ect       0  [1 = yes, 0 = no].
  ds_Q[,11] +                   # Q3  Where is [4 = not to me]                   1
  rowSums(1 - ds_Q[,12:18]) +   # Q4 [rev code]. If present = 0.                 0
  rowSums(ds_Q[,19:22]) +       # Q5-Q8 Always thought about it this way         4  [1 = agree]
  rowSums(6 - ds_Q[,23:26])     # Q9-Q12 [rev code]                              4

plot(ds_Q$QuestScoreRL,ds_Q$`questionnaire score`)



# Check using the "ideal synesthts":
unique(ds_Q[ds_Q$`questionnaire score` == 9,]$ID)

tmpID <- ds_Q %>%
  filter(ID %in% "28746")

# We want smaller values = synesthetes
tmpID$QuestScore5 <- tmpID[,2] + # Q1  "routinely think about sequences in space" 1 [1 = yes, 5 = no]
  rowSums(1 - tmpID[,3:10]) +    # Q2 [rev code]. If present month,num, ect       0  [1 = yes, 0 = no].
  tmpID[,11] +                   # Q3  Where is [4 = not to me]                   1
  rowSums(1 - tmpID[,12:18]) +   # Q4 [rev code]. If present = 0.                 0
  rowSums(tmpID[,19:22]) +       # Q5-Q8 Always thought about it this way         4  [1 = agree]
  rowSums(6 - tmpID[,23:26])     # Q9-Q12 [rev code]                              4


# I don't understand how the minimum value can be 9 rather than 10 ... (this also emerges from the pre-print)
# I think I need to find a way to match the questionnaire score first.


                       4

plot(ds_Q$QuestScore5,ds_Q$`questionnaire score`)
sum(abs(ds_Q$QuestScore5 - ds_Q$`questionnaire score`), na.rm = TRUE)





tmpID$`Q1 . Some people routinely think about sequences as arranged in a particular spatial configuration (as in the examples below), do you think this might apply to you? (1=strongly agree, 5= strongly disagree)` +
  reverse_code(tmpID$`Q2_numbers (1=present, 0=absent)`) +
  reverse_code(tmpID$`Q2_days  (1=present, 0=absent)`)   +
  reverse_code(tmpID$`Q2_months  (1=present, 0=absent)`) +
  reverse_code(tmpID$`Q2_years (1=present, 0=absent)`)   +
  reverse_code(tmpID$`Q2_letters (1=present, 0=absent)`) +
  reverse_code(tmpID$`Q2_temperature (1=present, 0=absent)`) +
  reverse_code(tmpID$`Q2_height (1=present, 0=absent)`) +
  reverse_code(tmpID$`Q2_weight (1=present, 0=absent)`) +
  tmpID$`Q3 Where do you tend to routinely experience these sequences? (1= in the space outside my body; 2= on an imagined space that has no real location; 3= inside my body; 4= this doesn't apply to me!)` +
  tmpID$`Q4_colours (1=present, 0=absent)` -
  tmpID$`Q4_shading (1=present, 0=absent)` -
  tmpID$`Q4_2D (1=present, 0=absent)` -
  tmpID$`Q4_3D (1=present, 0=absent)` -
  tmpID$`Q4_perspective (1=present, 0=absent)` -
  tmpID$`Q4-blocks-or-tiles (1=present, 0=absent)` -
  tmpID$`Q4_font (1=present, 0=absent)` -
  tmpID$`Q5 Before doing this experiment, I always thought about NUMBERS as existing in a particular spatial sequence (1= strongly agree; 5= strongly disagree)` -
  tmpID$`Q6 Before doing this experiment, I always thought about DAYS OF THE WEEK as existing in a particular spatial sequence (1= strongly agree; 5= strongly disagree)` -
  tmpID$`Q7 Before doing this experiment, I always thought about MONTHS OF THE YEAR as existing in a particular spatial sequence (1= strongly agree; 5= strongly disagree)` -
  tmpID$`Q8 I use this way of thinking about spatial sequences in my everyday life (1= strongly agree; 2= strongly disagree)` -
  tmpID$`Q9 When doing the experiment, I didn't have any strong intuition as to where to put the NUMBERS (1= strongly agree; 5= strongly disagree)` -
  tmpID$`Q10 When doing the experiment, I didn't have any strong intuition as to where to put the DAYS OF THE WEEK (1= strongly agree; 5= strongly disagree)` -
  tmpID$`Q11 When doing the experiment, I didn't have any strong intuition as to where to put the MONTHS OF THE YEAR (1= strongly agree; 5= strongly disagree)` -
  tmpID$`Q12 This experiment didn't really make much sense to me (1= strongly agree, 5= strongly disagree)` 

  
grepl("Q", colnames(tmpID))

ds_Ward2_Q$`questionnaire score` <- 