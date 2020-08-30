# Using Machine Learning for matchmaking
Using Machine Learning to find people with similar personalities &amp; interest for matchmaking

### Objective:
- Using clustering algorithms to cluster people based on their interests.
- Finding people for a random user from his cluster group.
- Ranking them based on how much their personality matches with the user's personality

### Datasets used:
- Big5 personality dataset: https://www.kaggle.com/tunguz/big-five-personality-test
- Interests dataset: https://www.kaggle.com/miroslavsabo/young-people-survey
- Baby-names dataset: https://osf.io/d2vyg/
  
  
### Approach:
1. Combining Big5 personality dataset with personality dataset
2. Adding names for ease in identification
3. Using PCA for dimention reduction in both Big5 and Interests columns
4. Using the PCA'd data to run heirarchical clustering
5. Finding the appropriate no of cluster from heirarchical clustering
6. Clustering the data using K-Means Clustering
7. Attaching cluster assignments to the original PCA'd dataset
8. Selecting a user
9. Filtering out people within same cluster, country, age-group as user's
10. Creating a list of people with personality most similar to user's
  
  
  
### The Big5 dataset:   

The Big5 data was collected (c. 2012) through on interactive online Big5 personality test (also known as OCEAN personalities). Participants were informed that their responses would be recorded and used for research at the begining of the test and asked to confirm their consent at the end of the test.

The following items were rated on a five point scale where 1=Disagree, 3=Neutral, 5=Agree (0=missed). All were presented on one page in the order E1, N2, A1, C1, O1, E2...... 

O = Openness
O1	I have a rich vocabulary.
O2	I have difficulty understanding abstract ideas.
O3	I have a vivid imagination.
O4	I am not interested in abstract ideas.
O5	I have excellent ideas.
O6	I do not have a good imagination.
O7	I am quick to understand things.
O8	I use difficult words.
O9	I spend time reflecting on things.
O10	I am full of ideas.

C = Conscientiousness
C1	I am always prepared.
C2	I leave my belongings around.
C3	I pay attention to details.
C4	I make a mess of things.
C5	I get chores done right away.
C6	I often forget to put things back in their proper place.
C7	I like order.
C8	I shirk my duties.
C9	I follow a schedule.
C10	I am exacting in my work.

E = Extraversion
E1	I am the life of the party.
E2	I don't talk a lot.
E3	I feel comfortable around people.
E4	I keep in the background.
E5	I start conversations.
E6	I have little to say.
E7	I talk to a lot of different people at parties.
E8	I don't like to draw attention to myself.
E9	I don't mind being the center of attention.
E10	I am quiet around strangers.

A = Agreeableness
A1	I feel little concern for others.
A2	I am interested in people.
A3	I insult people.
A4	I sympathize with others' feelings.
A5	I am not interested in other people's problems.
A6	I have a soft heart.
A7	I am not really interested in others.
A8	I take time out for others.
A9	I feel others' emotions.
A10	I make people feel at ease.

N = Neurotocism
N1	I get stressed out easily.
N2	I am relaxed most of the time.
N3	I worry about things.
N4	I seldom feel blue.
N5	I am easily disturbed.
N6	I get upset easily.
N7	I change my mood a lot.
N8	I have frequent mood swings.
N9	I get irritated easily.
N10	I often feel blue.

On the next page the following values were collected.

Race: 1=Mixed Race, 2=Arctic (Siberian, Eskimo), 3=Caucasian (European), 4=Caucasian (Indian), 5=Caucasian (Middle East), 6=Caucasian (North African, Other), 7=Indigenous Australian, 8=Native American, 9=North East Asian (Mongol, Tibetan, Korean Japanese, etc), 10=Pacific (Polynesian, Micronesian, etc), 11=South East Asian (Chinese, Thai, Malay, Filipino, etc), 12=West African, Bushmen, Ethiopian, 13=Other (0=missed)

Age:	entered as text (individuals reporting age < 13 were not recorded)

Engnat:	Response to "is English your native language?". 1=yes, 2=no (0=missed)

Gender:	Chosen from a drop down menu. 1=Male, 2=Female, 3=Other (0=missed)

Hand:	"What hand do you use to write with?". 1=Right, 2=Left, 3=Both (0=missed)



### Interests data:

Interests dataset measures a person's response to following topics on a scale of 1 to 5:
Music, Classical music, Musical, Pop, Rock,Metal or Hardrock, "Hiphop, Rap", Rock n roll, Alternative, "Techno, Trance",
Movies, Horror, Thriller, Comedy, Romantic, Sci-fi, War, Fantasy/Fairy tales, Animated, Documentary, Action, 
History, Psychology, Politics, Mathematics, Physics, Internet, PC, Economy Management, Biology, Chemistry, Reading, Geography, Foreign languages, Medicine, Law,
Cars, Art exhibitions, Religion, Dancing, Musical instruments, Writing, Passive sport, Active sport, Science and technology, Theatre, Adrenaline sports, Pets, Appearence and gestures,
Happiness in life, Education



#### You can connect with me on:

#### [LinkedIn](https://www.linkedin.com/in/shariq06ahmed/)

#### [GitHub](https://github.com/ShariqAhmed007)
