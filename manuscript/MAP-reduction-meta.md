---
classoptions: 
  - sn-nature      
  - referee         # Optional: Use double line spacing 
  # - lineno        # Optional: Add line numbers
  # - iicol         # Optional: Double column layout
title: "Meaningfully reducing consumption of meat and animal products is an unsolved problem: results from a meta-analysis"
titlerunning: MAP-reduction-meta
authors: 
  - firstname: Seth Ariel
    lastname: Green
    email: setgree@stanford.edu
    affiliation: 1
    corresponding: TRUE
  - firstname: Maya B.
    lastname: Mathur
    affiliation: 1
  - firstname: Benny
    lastname: Smith 
    affiliation: 2
affiliations:
  - number: 1
    info:
      orgdiv: Humane and Sustainable Food Lab
      orgname: Stanford University
  - number: 2
    info:
      orgname: Allied Scholars for Animal Protection 
keywords:
  - meta-analysis
  - meat
  - plant-based
  - randomized controlled trial
  
abstract: |
  Which theoretical approach leads to the broadest and most enduring reductions in consumptions of meat and animal products (MAP)? We address these questions with a theoretical review and meta-analysis of rigorous randomized controlled trials with consumption outcomes. We meta-analyze 36 papers comprising 42 studies, 114 interventions, and approximately 88,000 subjects. We find that these papers employ four major strategies to changing behavior: choice architecture, persuasion, psychology, and a combination of persuasion and psychology. The pooled effect of all 114 interventions on MAP consumption is $\Delta$ = 0.065, indicating an unsolved problem. Reducing consumption of red and processed meat is an easier target: $\Delta$ = 0.249, but because of missing data on potential substitution to other MAP, we can’t say anything definitive about the consequences of these interventions on animal welfare. We further explore effect size heterogeneity by approach, population, and study features. We conclude that while no theoretical approach provides a proven remedy to MAP consumption, designs and measurement strategies have generally been improving over time, and many promising interventions await rigorous evaluation.
date: "2024-10-13"
output: 
  rticles::springer_article:
    keep_tex: true
    keep_md: true

bibliography: "./vegan-refs.bib"
editor_options: 
  chunk_output_type: console
header-includes:
  - \usepackage{comment}
  - \usepackage{anyfontsize}
  - \usepackage{caption}
  - \usepackage{}
---



# Introduction {#sec1}

Reducing global consumption of meat and animal products (MAP) is vital to reducing chronic disease and the risk of zoonotic pandemics [@willett2019; @landry2023; @hafez2020], abating environmental degradation and climate change [@poore2018; @koneswaran2008; @greger2010], and improving animal welfare [@kuruc2023; @scherer2019].
However, MAP is widely regarded as normal, necessary, and a dietary staple [@piazza2022; @milford2019].
Global MAP consumption is increasing annually [@godfray2018] and expected to continue doing so [@whitton2021].

There is a vast and diverse literature investigating potential means to reverse this trend.
Example approaches include providing free access to meat substitutes [@katare2023], changing the price [@horgen2002] or perceptions [@kunst2016] of meat, or attempting to persuade people to change their diets [@bianchi2018conscious].
A large portion of this literature seeks to alter the contexts in which MAP is selected [@bianchi2018restructuring], for instance by changing menu layouts [@bacon2018; @gravert2021] or placing vegetarian items more prominently in dining halls [@ginn2024].
Some interventions are associated with large impacts [@hansen2021; @boronowsky2022; @reinders2017], and prior reviews have concluded that some frequently studied approaches, such as using persuasive messaging that appeals to animal welfare [@mathur2021meta] or making vegetarian meals the default [@meier2022]  may be consistently effective. 
Governments, universities, and other institutions are increasingly implementing these ideas in such settings as dining halls [@pollicino2024] and hospital cafeterias [@morgenstern2024].

However, much of this literature is beset by design and measurement limitations.
Many interventions are either not randomized [@garnett2020] or underpowered [@delichatsios2001].
Others record outcomes that are imperfect proxies MAP consumption, such as attitudes and intentions [@mathur2021effectiveness], yet behaviors often do not track with these psychological processes [@porat2024].
Further, many studies measure only immediate impacts [@hansen2021; @griesoph2021] rather than longer-term effects, or focus on hypothetical choices [@raghoebar2020; @vermeer2010].
Last, numerous studies that aim to reduce consumption of red and processed meat (RPM) may induce people to switch to other forms of MAP, such as chicken or fish [@grummon2023].
While RPM is of special concern for health and greenhouse gas emissions [@abete2014; @lescinsky2022], increasing chicken or fish consumption may lead to substantially worse outcomes for animal welfare [@mathur2022ethical], and fails to reduce the risk of zoonotic outbreaks from factory farms [@hafez2020] or land and water pollution [@grvzinic2023].

In the past few years, a new wave of MAP reduction research has made commendable methodological advances in design, outcome measurement validity, and statistical power.
Historically, in some scientific fields, strong effects detected in early studies with methodological limitations were ultimately overturned by more rigorous follow-ups [@wykes2008; @paluck2019; @scheel2021].
Does this phenomenon hold in the MAP reduction literature as well?



We answer this question with a meta-analysis of rigorously designed RCTs aimed at creating lasting reductions in MAP consumption [@andersson2021; @kanchanachitra2020; @abrahamse2007; @acharya2004; @banerjee2019; @bianchi2022; @bochmann2017; @bschaden2020; @carfora2023; @cooney2014; @cooney2016; @feltz2022; @haile2021; @hatami2018; @hennessy2016; @jalil2023; @mathur2021effectiveness; @merrill2009; @norris2014; @peacock2017; @polanco2022; @sparkman2021; @weingarten2022; @piester2020; @aldoh2023; @allen2002; @camp2019; @coker2022; @sparkman2020; @berndsen2005; @bertolaso2015; @fehrenbach2015; @mattson2020; @shreedhar2021].
These RCTs all measured consumption outcomes at least a single day after treatment was first administered, and all had at least 25 subjects in both treatment and control, or, in the case of cluster-assigned studies, at least ten clusters in total. 
Additionally, we coded a separate dataset of 17 papers that otherwise met our inclusion criteria but instead measured changes in consumption of RPM [@anderson2017; @carfora2017correlational; @carfora2017randomised; @carfora2019; @carfora2019informational; @delichatsios2001talking; @dijkstra2022; @emmons2005cancer; @emmons2005project; @jaacks2014; @james2015; @lee2018; @lindstrom2015;  @perino2022; @schatzkin2000; @sorensen2005; @wolstenholme2020].

Studies in our meta-analytic database pursued one of four theoretical approaches: choice architecture (the manipulation of how MAP is presented to diners), psychological appeals (typically manipulations of perceived norms around eating meat), explicit persuasion (centered around animal welfare, the environment, and/or health), or a combination of psychological and persuasion messages.
Interventions varied in delivery method, for example, documentary films [@mathur2021effectiveness], leaflets [@peacock2017], university lectures [@jalil2023], op-eds [@haile2021], and changes to menus in cafeterias [@andersson2021] and restaurants [@coker2022; @sparkman2021].

We estimated overall effect sizes as well as effect sizes associated with different theoretical approaches and delivery mechanisms.
Although we find some heterogeneity across theories and mechanisms, we find consistently smaller effects on MAP consumption than previous reviews have suggested [@bianchi2018restructuring; @byerly2018; @chang2023; @harguess2020; @kwasny2022; @mathur2021meta; @meier2022; @pandey2023], with some intriguing exceptions.
Thus, contradicting previous reviews that analyzed a wider array of designs and outcomes, we conclude that meaningfully reducing MAP consumption is an unsolved problem.
However, many promising approaches still await rigorous evaluation.

# Results {#sec2}

## Descriptive overview
Our dataset comprises 34 papers, 40 studies, and 108 separate point estimates, each corresponding to a distinct intervention.
These studies reached approximately 87,000 subjects (caveat that this is a broad approximation: many interventions were administered at the level of day or cafeteria and did not record how many individuals were assigned to treatment).



The earliest paper was published in 2002 [@allen2002] and a majority (18 of 34 papers) have been published since 2020. Among studies where treatment was assigned to individuals rather than by clusters, the median analyzed sample size per study was 131 subjects (25th percentile: 108; 75th percentile: 214).

## Constituent Theories

**Choice Architecture** studies [@andersson2021; @kanchanachitra2020] manipulate aspects of physical environments to reduce MAP consumption, e.g. placing vegetarian option at eye level on a cafeteria menu [@andersson2021] or providing diners with spoons that make it harder for people to serve themselves fish sauce [@kanchanachitra2020]. 

**Persuasion** studies [@kanchanachitra2020; @abrahamse2007; @acharya2004; @banerjee2019; @bianchi2022; @bochmann2017; @bschaden2020; @carfora2023; @hennessy2016; @piester2020; @cooney2014; @cooney2016; @feltz2022; @haile2021; @hatami2018; @jalil2023; @mathur2021effectiveness; @merrill2009; @norris2014; @peacock2017; @polanco2022; @sparkman2021; @weingarten2022] appeal directly to people to eat less MAP.
Arguments focus on health, the environment (usually climate change), and animal welfare.
 [@jalil2023].

\begin{comment}
Some are designed to be emotionally activating, e.g. presenting upsetting footage of factory farms [@polanco2022], while others present information more factually, for instance about the relationship between diet and cancer [@hatami2018].
Many persuasion studies combine arguments, such as a lecture on the health and environmental consequences of eating meat
These studies formed the majority of our database.
\end{comment}

**Psychology** studies [@aldoh2023; @allen2002; @camp2019; @coker2022; @piester2020; @sparkman2020] manipulate the interpersonal,cognitive, or affective factors associated with eating meat.
The most common psychological intervention is centered on social norms seeking to alter the perceived popularity of non-MAP dishes [@sparkman2020].

\begin{comment}
Norms might be descriptive, stating how many people engaged in the desired behavior [@aldoh2023], or dynamic, telling subjects that the number of people reducing their MAP consumption is increasing over time [@aldoh2023; @coker2022; @sparkman2020].
Another study looked at response inhibition training, where subjects are trained to associate meat with an inhibiting response [@camp2019].
The first psychology study meeting our inclusion criteria was published in 2017.
\end{comment}

Finally, a group of interventions combines **persuasion** approaches with **psychological** appeals to reduce MAP consumption [@berndsen2005; @bertolaso2015; @carfora2023; @fehrenbach2015; @hennessy2016; @mathur2021effectiveness; @mattson2020; @piester2020; @shreedhar2021]. These studies typically combine a persuasive message with a norms-based appeal [@piester2020; @mattson2020] or an opportunity to pledge to reduce one's meat consumption [@mathur2021effectiveness; @shreedhar2021].

## Meta-analytic results



In our dataset, the pooled effect of all interventions is $\Delta$ = 0.066 (95% CI: [[0.018, 0.114]], p = 0.0094, $\rho$ = 0.8. We estimate that 24.1% of true effects are above $\Delta$ = 0.1, and just 6.5 are above $\Delta$ = 0.2.  

Table 2 compares the overall meta-analytic estimate to the estimates associated with the four major theoretical approaches, as well as the three categories of persuasion.

```{=tex}
\begin{center}
[Table 2 about here]
\end{center}
```

```{=tex}
\begin{center}
[Figure 1 about here]
\end{center}
```


By contrast, reducing consumption of red and processed meat is an easier target. Across 17 studies and 25 point estimates, we detect a pooled effect of $\Delta$ = 0.249
(95% CI: [[0.113, 0.385]], p = 0.0016, $\rho$ = 0.8. We estimate that 52% of true effects are above $\Delta$ = 0.2.

## Moderators analysis


Our sample of studies is comparatively small, and many differences between studies are confounded.
For example, 17 of 18 interventions with objectively reported outcomes are also studies of university populations.
Nevertheless we explore potential moderators in terms of  of potential moderators of effect size. Table 2 displays effect sizes for differences by population, region, era of publication, publication venue, delivery method, and outcome recording strategy.

```{=tex}
\begin{center}
[Table 2 about here]
\end{center}
```


# Methods {#sec3}


## Tables

**Table 1**



**Table 2**


## Figures


\includegraphics{./figures/forest_plot-1} 

Figure 1 about here.



\newpage
# References
