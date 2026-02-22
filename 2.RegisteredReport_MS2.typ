// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}

//#assert(sys.version.at(1) >= 11 or sys.version.at(0) > 0, message: "This template requires Typst Version 0.11.0 or higher. The version of Quarto you are using uses Typst version is " + str(sys.version.at(0)) + "." + str(sys.version.at(1)) + "." + str(sys.version.at(2)) + ". You will need to upgrade to Quarto 1.5 or higher to use apaquarto-typst.")

// counts how many appendixes there are
#let appendixcounter = counter("appendix")
// make latex logo
// https://github.com/typst/typst/discussions/1732#discussioncomment-11286036
#let TeX = {
  set text(font: "New Computer Modern",)
  let t = "T"
  let e = text(baseline: 0.22em, "E")
  let x = "X"
  box(t + h(-0.14em) + e + h(-0.14em) + x)
}

#let LaTeX = {
  set text(font: "New Computer Modern")
  let l = "L"
  let a = text(baseline: -0.35em, size: 0.66em, "A")
  box(l + h(-0.32em) + a + h(-0.13em) + TeX)
}

#let firstlineindent=0.5in

// documentmode: man
#let man(
  title: none,
  runninghead: none,
  margin: (x: 1in, y: 1in),
  paper: "us-letter",
  font: ("Times", "Times New Roman"),
  fontsize: 12pt,
  leading: 18pt,
  spacing: 18pt,
  firstlineindent: 0.5in,
  toc: false,
  lang: "en",
  cols: 1,
  numbersections: false,
  numberdepth: 3,
  first-page: 1,
  suppresstitlepage: false,
  doc,
) = {

  if suppresstitlepage {counter(page).update(first-page)}

  set page(
    margin: margin,
    paper: paper,
    header-ascent: 50%,
    header: grid(
      columns: (9fr, 1fr),
      align(left)[#upper[#runninghead]],
      align(right)[#context counter(page).display()]
    )
  )
  

  

 

  set table(    
    stroke: (x, y) => (
        top: if y <= 1 { 0.5pt } else { 0pt },
        bottom: .5pt,
      )
  )

  set par(
    justify: false, 
    leading: leading,
    first-line-indent: firstlineindent
  )

  // Also "leading" space between paragraphs
  set block(spacing: spacing, above: spacing, below: spacing)

  set text(
    font: font,
    size: fontsize,
    lang: lang
  )
  
  show link: set text(blue)
  show "al.'s": "al.\u{2019}s"

  show quote: set pad(x: 0.5in)
  show quote: set par(leading: leading)
  show quote: set block(spacing: spacing, above: spacing, below: spacing)
  // show LaTeX
  show "TeX": TeX
  show "LaTeX": LaTeX

  // format figure captions
  show figure.where(kind: "quarto-float-fig"): it => block(width: 100%, breakable: false)[
    #if int(appendixcounter.display().at(0)) > 0 [
      #heading(level: 2, outlined: false)[#it.supplement #appendixcounter.display("A")#it.counter.display()]
    ] else [
      #heading(level: 2, outlined: false)[#it.supplement #it.counter.display()]
    ]
    #align(left)[#par[#emph[#it.caption.body]]]
    #align(center)[#it.body]
  ]
  
  // format table captions
  show figure.where(kind: "quarto-float-tbl"): it => block(width: 100%, breakable: false)[#align(left)[
  
    #if int(appendixcounter.display().at(0)) > 0 [
      #heading(level: 2, outlined: false, numbering: none)[#it.supplement #appendixcounter.display("A")#it.counter.display()]
    ] else [
      #heading(level: 2, outlined: false, numbering: none)[#it.supplement #it.counter.display()]
    ]
    #par[#emph[#it.caption.body]]
    #block[#it.body]
  ]]
  
    set heading(numbering: "1.1")
    
    show heading: set text(size: fontsize)


 // Redefine headings up to level 5 
  show heading.where(
    level: 1
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(center)
    #if(numbersections and it.outlined and numberdepth > 0 and counter(heading).get().at(0) > 0) [#counter(heading).display()] #it.body
  ]
  
  show heading.where(
    level: 2
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(left)
    #if(numbersections and it.outlined and numberdepth > 1 and counter(heading).get().at(0) > 0) [#counter(heading).display()] #it.body
  ]
  
  show heading.where(
    level: 3
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(left)
    #set text(style: "italic")
    #if(numbersections and it.outlined and numberdepth > 2 and counter(heading).get().at(0) > 0) [#counter(heading).display()] #it.body
  ]

  show heading.where(
    level: 4
  ): it => text(
    weight: "bold",
    it.body
  )

  show heading.where(
    level: 5
  ): it => text(
    weight: "bold",
    style: "italic",
    it.body
  )
  
  

  if cols == 1 {
    doc
  } else {
    columns(cols, gutter: 4%, doc)
  }
  



}


#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)

#show: document => man(
  runninghead: "SPACE-SEQUENCE SYNESTHESIA: OPTIMIZING CONSISTENCY TESTS",
  numberdepth: 3,
  document,
)

\
\
#block[
#heading(
level: 
1
, 
numbering: 
none
, 
outlined: 
false
, 
[
Pre-registered report: Mapping Synesthetic Sequences in Space: Improving Consistency Test by Harnessing Cartography Tools.
]
)
]
#set align(center)
#block[
\
Rémy Lachelin, Chhavi Sachdeva, and Nicolas Rothen

Psychology, UniDistance Suisse

]
#set align(left)
\
\
#block[
#heading(
level: 
1
, 
numbering: 
none
, 
outlined: 
false
, 
[
Author Note
]
)
]
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Rémy Lachelin #box(image("_extensions/wjschne/apaquarto/ORCID-iD_icon-vector.svg", width: 4.23mm)) #link("https://orcid.org/0000-0002-8485-7153")

Chhavi Sachdeva #box(image("_extensions/wjschne/apaquarto/ORCID-iD_icon-vector.svg", width: 4.23mm)) #link("https://orcid.org/0000-0002-0074-4371")

Nicolas Rothen #box(image("_extensions/wjschne/apaquarto/ORCID-iD_icon-vector.svg", width: 4.23mm)) #link("https://orcid.org/0000-0002-8874-8341")

Author roles were classified using the Contributor Role Taxonomy (CRediT; https:\/\/credit.niso.org/) as follows: #emph[Rémy Lachelin];#strong[: ];conceptualization, methodology, formal analysis, data curation, and Writing - Original Draft. #emph[Chhavi Sachdeva];#strong[: ];conceptualization, methodology, and Writing - Review & Editing. #emph[Nicolas Rothen];#strong[: ];conceptualization, Writing - Review & Editing, supervision, project administration, and Founding Acquisition

Correspondence concerning this article should be addressed to Rémy Lachelin, Psychology, UniDistance Suisse, Schinerstrasse 18, Brig-Glis, Valais 3900, Email: #link("mailto:remy.lachelin@fernuni.ch")[remy.lachelin\@fernuni.ch]

#pagebreak()

#block[
#heading(
level: 
1
, 
numbering: 
none
, 
outlined: 
false
, 
[
Abstract
]
)
]
#block[
Sequence-space synesthesia is a perceptual condition in which ordinal sequences (e.g., numbers, days of the week, or months of the year) are experienced as occupying specific spatial locations. This perceptual condition is identified using self-reports (e.g.~questionnaires) and behavioural consistency tasks. Existing consistency tests measure the spatial distance between responses to repeated stimuli, but they ignore the ordinal and geometric features of spatial-forms. This preregistered study consists of a present and future analyses. In the present analyses, we optimise SSS diagnostics from consistency test by extracting novel geometric features at the spatial-form level. To do this, we first evaluate classification performances of old and new features in a large (N = 685) aggregated sample from four available and independent datasets. We then harness a geographic toolbox to extract metrics from the spatial-forms level. Finally, receiver operating characteristic (ROC) analyses are conducted to assess the discriminative performances of each method. The results show that permuted topological validity of spatial-forms and the perimeter between stimuli performs equally well in detecting SSS. In a future study, we will examine predictive validity of the selected methods on an independent dataset that has yet to be collected. Findings from the present study highlight the relevance of topological principles for sequence-space representations and aims to optimise the ability of consistency tests to detect SSS.

]
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
#emph[Keywords];: Sequence space synaesthesia, Synaesthesia/synesthesia, consistency test, space, time, numbers

#pagebreak()

#block[
#heading(
level: 
1
, 
numbering: 
none
, 
outlined: 
false
, 
[
Pre-registered report: Mapping Synesthetic Sequences in Space: Improving Consistency Test by Harnessing Cartography Tools.
]
)
]
= Introduction
<sec-introduction>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Sequence-Space Synaesthesia (SSS) or visuo-spatial forms is the phenomenon where people visualize ordered sequences in particular spatial positions. For example, numbers, weekdays or months (synesthetic #emph[inducers];) are represented as arranged into specific spatial positions in space (synesthetic #emph[concurrent];). The synaesthetic spatial-forms can be complex and have variable geometric forms. Those geometric forms might be different for each categories (i.e.~number-forms weekdays and months), with forms such as ellipses, zig-zags or curbed lines Flournoy (#link(<ref-flournoy1893>)[1893];). SSS are usually identified using questionnaires and consistency tests. An individual is identified as SSS based on the variability at the stimulus level between repeated responses: less variable responses being an indicator of the consistent response characteristic of SSS. However, stimulus level consistency can also be achieved by responding to the same position for all stimuli. Furthermore, it might favour linear over circular spatial-forms and is not informed about the ordinality between stimuli (e.g.~1 `→` 2 `→` 3, etc.). Here, we aim at optimizing the identification of SSS from consistency tasks using geometrical characteristics of spatial-forms from ordered stimuli or inducers.

SSS frequently co-occurs with other subtypes of synaesthesia and as for other subtypes of synaesthesia it's idiosyncratic. Colour-grapheme synaesthesia, where a grapheme #emph[inducer] triggers a #emph[concurrent] colour (i.e.~"A" seen as red), co-occurs at 71 % to 76 % with SSS (#link(<ref-sagiv2006>)[Sagiv et al., 2006];). Nevertheless, across different synaesthetic subtypes, self-reported SSS tend to cluster together (#link(<ref-ward2022>)[Ward & Simner, 2022];), indicating a degree of internal homogeneity and justifying to study it as a distinct phenomenon. Spatial-forms are idiosyncratic, which results in considerable heterogeneity in how this phenomenon is manifested across individuals. One source of heterogeneity is given by dimensionality: some SSS experiences can involve three-dimensional (3D) and two-dimensional (2D) arrangements (#link(<ref-eagleman2009a>)[Eagleman, 2009];; #link(<ref-price2013>)[Price & Pearson, 2013];). Another source of heterogeneity is the reference frame, for example, the spatial-forms might take place in an external space around the body (#emph[i.e.] projector) or in an egocentric internal space (#emph[i.e.] associator) (#link(<ref-dixon2004>)[Dixon et al., 2004];; #link(<ref-smilek2007>)[Smilek et al., 2007];). Further variability can be explained by temporal-spatial properties and mental-manipulation of spatial-forms such as "zooming" in and out or rotating or shifting perspectives at will (#link(<ref-gould2014>)[Gould et al., 2014];; #link(<ref-jarick2009>)[Jarick et al., 2009];) Lastly, the shape, complexity and layout of the spatial-forms are also heterogeneous such as forming for example ovals, lines, zig-zags or loops. With some recurring shapes being more frequent across SSS, such as ovals for months (#link(<ref-eagleman2009a>)[Eagleman, 2009];).

Despite the after mentioned heterogeneities, SSS is also phenomenological characterized. There might be five main characteristics for synaesthesia in general and specifically SSS (#link(<ref-deroy2013>)[Deroy & Spence, 2013];; #link(<ref-seron1992>)[Seron et al., 1992];). #emph[Automaticity];: the inducer automatically triggers the concurrent. #emph[Unidirectionality];: while the #emph[inducer] triggers the concurrent, the concurrent does not trigger the inducer. #emph[Developmentally];: the experience was already present during childhood. #emph[Consciousness];: The concurrent is consciously perceived. #emph[Consistency];: the inducer-concurrent pair remains stable in time within subject. While some of these characteristics can be captured with self-reported questionnaire (i.e.~for development and consciousness), other can be quantified more objectively using behavioural tasks such as consistency tests (#link(<ref-baron-cohen1993>)[Baron-Cohen et al., 1993];).

== Consistency tests
<sec-consistency-tests>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Consistency tests are extracted form behavioural tasks used to evaluate how stable synesthetic experiences are over time ((#link(<ref-rothen2013a>)[Rothen et al., 2013];, #link(<ref-rothen2016>)[2016a];)). They do this by presenting the same stimuli repeatedly and assessing how similar participant's responses are across repetitions (i.e.~#emph[inducer];-#emph[concurrent] associations). High consistency is often taken as evidence for synaesthesia. Consistency tests have proven effective for colour-grapheme synaesthesia. Measures of individual consistency can be derived using colour pickers while repeatedly presenting the same inducer (i.e.~"A"). The quantification of the distance between concurrents from the same inducers is used to discriminate consistent synaesthetes from controls. Specifically, the euclidean distance in CIE L\*u\*v colour space, which is designed for perceptual uniformity, yields optimal classification accuracy when using a cut-off estimated as deduced from a larger representative sample(#link(<ref-rothen2013a>)[Rothen et al., 2013];). A similar rationale to that used for colour-grapheme synaesthesia has been applied to characterize SSS from consistency tasks.

In the SSS consistency task, participants complete multiple rounds of the same stimuli (e.g., digits, days of the week, and months of the year) and are asked to indicate a spatial location for each stimulus by clicking on the computer screen. Brang et al. (#link(<ref-brang2010>)[2010];) for example evaluated consistency as the distance between repeated responses to the same inducer or stimuli (e.g.~January and January) relative to adjacent stimuli (e.g.~February). A response was defined as consistent if it fell within 1.96 #emph[z-scores];. However, this criterion was noted to be potentially too conservatory, as it identified synaesthesia in 4 of 81 self-reported synaesthetes. Geometrical features such as area and perimeter between the coordinates of repeated inducers have further been used as a measure of the distance between same inducers, hence as a metric for consistency. Less consistent responses leading to smaller triangle perimeters and area (#link(<ref-rothen2016>)[Rothen et al., 2016a];). A cut-off corresponding to less than 0.203 % average responses area in proportion to the total screen area to classify as SSS has been suggested (see also #link(<ref-ward2018>)[Ward et al., 2018];).

However, several general caveats of consistency tests using concurrent or stimulus level metrics have been identified. Some tests may favour certain spatial-forms (#link(<ref-ward2018>)[Ward et al., 2018];) in particular those with linear or highly regular spatial layouts, i.e.~elliptical patterns for months(#link(<ref-brang2010>)[Brang et al., 2010];; #link(<ref-eagleman2009a>)[Eagleman, 2009];; #link(<ref-flournoy1893>)[Flournoy, 1893];). Another concern is that participants that respond with the same position, for example when not knowing the response, will have artificially high consistencies with those metrics (#link(<ref-rothen2016>)[Rothen et al., 2016a];). This has led to alternative approaches such as to add the standard deviation of responses, questionnaire cut-off (#link(<ref-ward2018>)[Ward et al., 2018];) or permutation-based comparison of individual responses to chance levels for colour-grapheme(#link(<ref-root2021>)[Root et al., 2021];) and SSS (#link(<ref-ward2022a>)[Ward, 2022];). Finally, these consistency tests evaluate the variability of responses to the same stimuli, therefore the ordinality between stimuli is not taken into account. Synaesthetic spatial-forms follow ordinal rules (e.g.~Monday `→` Tuesday `→` Wednesday). In the domain of numerical cognition, ordinality has been identified as an important information when processing sequences (#link(<ref-lyons2013>)[Lyons & Beilock, 2013];). Some studies of SSS have systematically investigated ordinality by investigating metrics of adjacent inducer-concurrent pairs such as distances (#link(<ref-brang2010>)[Brang et al., 2010];) or angles (#link(<ref-eagleman2009a>)[Eagleman, 2009];). However, ordinality of the concurrent spatial-form might be particularly relevant considering all the stimuli of a certain category (i.e.~weekdays or months). The spatial-forms of the concurrents are often spatially structured into configuration such as lines or polygons that may follow distinctive geometrical rules. For example linear layouts have been described in early accounts of number forms (#link(<ref-flournoy1893>)[Flournoy, 1893];; #link(<ref-galton1880>)[Galton, 1880];).

== Present study
<present-study>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
The goal of this registered report is to compare different consistency tests on their classification performances of individuals with SSS and controls doing the consistency task using Receiver Operator Characteristics (ROC) analyses. In the present #emph[Phase I];, we merge four previously available datasets using the same task on both SSS and control groups (#link(<ref-ward2022a>)[Ward, 2022];). First, we aimed to reproduce established consistency test methods based on stimulus-level consistency metrics, such as area and perimeter. Second, we explored a new approach comparing geometrical features across repetitions of the same categories (weekday, month and numbers), such as segments and polygons. These novel features are designed to take advantage of the sequentiality or ordinality between the responses and the geometrical properties at the spatial-form level, see #link(<fig-Ex01>)[Figure~1];. All the consistency tests are then compared using ROC analyses on their correct classification performances of self-reported SSS and control groups.

In a future study, we will assess whether the tests identified in the present study generalize and are validated on an independent dataset that is yet to be acquired (Sachdeva et al. (#link(<ref-sachdeva2024>)[2024];), Stage 1 in-principle acceptance, see also #link("https://osf.io/6wn4m");).

= Methods
<methods>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Code and data for "one-click" reproducibility of this manuscript including the following analyses are available on git-hub (#link("https://github.com/remLach/SpaceSequenceSynDiagnostic");). All the analyses are conducted in R, using the following packages 'pROC' v. 1.19.0.1 (#link(<ref-pROC>)[Robin et al., 2011];), 'sf' v. 1.0.21 (#link(<ref-sf>)[Pebesma & Bivand, 2023];) and for visualization 'ggplot2' v. 4.0.1 (#link(<ref-ggplot2>)[Wickham, 2016];), 'ggVennDiagram' v. 1.5.6 (#link(<ref-ggVennDiagram>)[Gao & Dusa, 2025];)

== #emph[Datasets and Participants]
<datasets-and-participants>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
To base the feature optimization on the largest possible sample we looked for accessible datasets that used the consistency test on groups of synesthetes and controls. We found four datasets that met these criteria. Two datasets were collected in laboratory settings Rothen et al. (#link(<ref-rothen2016>)[2016a];) (see also #link("https://osf.io/6hq94/files/osfstorage")[https:\/\/osf.io/6hq94];) and Van Petersen et al. (#link(<ref-vanpetersen2020>)[2020];) (see also #link("https://data.ru.nl/collections/di/dcc/DSC_2018.00019_653");). The two others came from on-line testing Ward (#link(<ref-ward2022a>)[2022];) (see also #link("https://osf.io/nu5v4/overview")[https:\/\/osf.io/nu5v4];) and an additional dataset was gently provided by private communications with Professor Ward. To match the other datasets, stimuli of the weekdays and months categories were translated from Dutch to English in the dataset from (#link(<ref-vanpetersen2020>)[Van Petersen et al., 2020];). For the number category we kept only digits from 0 to 9 that where presented across all datasets (excluding the stimuli "50" and "100" for numbers in Van Petersen et al. (#link(<ref-vanpetersen2020>)[2020];)).

From the merged datasets, we kept 685 from the total 689 participants. First, we excluded 0.02 % empty trials (i.e.~skipped responses) including trials flagged for having the same x or y coordinates across conditions and repetitions, causing the depletion n = 2 participants(as in #link(<ref-rothen2016a>)[Rothen et al., 2016b];; #link(<ref-ward2018>)[Ward et al., 2018];). n = 2 participants were excluded for having less than 4 coordinate points since polygons need at least four coordinate. Note therefore, that 31 participants of the final sample did not have responses in all three conditions X repetition cases. From the final sample of N = 685, 396 were synaesthetes and 289 controls, see #link(<tbl-mytable01>)[Table~1] and #link(<tbl-mytable02>)[Table~2];.

Regarding the synaesthets profiles, detailed participant information such as questionnaire responses were only available from the two datasets from the data by Professor Ward (i.e.~a majority of 573 participants). We described the self-reported profiles for the stimulus categories used in the consistency test (i.e.~number, weekdays and month), see #link(<fig-myplot01>)[Figure~2];. From this Venn-diagram we see that 240 of the SSS report having spatial-forms for Numbers, Days and Month; 42 only Days and Month; 21 only Number and Day. Also, 127 controls report spatial-forms for either Days, Numbers, Months or combinations.

== Procedure and analysis
<procedure-and-analysis>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
For the consistency task, each stimuli were presented randomly and sequentially centrally on the screen. Participant were instructed to click on the screen position where they visualize them. In Van Petersen et al. (#link(<ref-vanpetersen2020>)[2020];) and Rothen et al. (#link(<ref-rothen2016>)[2016a];) the participants were allowed to skip responses.

Stimulus included here were 7 weekdays (Monday to Sunday), 12 months (January to December) and 9 numbers (0 to 9). For all the data from Professor Ward the stimuli were presented in randomized order with the constraint that no stimulus was repeated until all unique stimuli (N = 29) had been presented once. The median display resolution was 1440 X 768, with a maximum of 2560 X 2025 and a minimum of 308 X 149.

== #emph[Stimulus level];: area and perimeter between repetitions
<stimulus-level-area-and-perimeter-between-repetitions>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
First, we reproduced the tests extracted from consistency tasks found in the literature such as area and perimeter between repetitions (#link(<ref-rothen2016>)[Rothen et al., 2016a];; #link(<ref-vanpetersen2020>)[Van Petersen et al., 2020];; #link(<ref-ward2022a>)[Ward, 2022];). Formally, the area (see #ref(<eq-area>, supplement: [Equation])) and perimeter (see #ref(<eq-perim>, supplement: [Equation])) are calculated from the triangle (i.e.~given three repetitions) formed by the #emph[x] and #emph[y] coordinates of the three repetitions of each stimuli (i.e.~#emph[(x1, y1), (x2, y2), (x3, y3)];).

#math.equation(block: true, numbering: "(1)", [ $ A r e a = lr(|x 1 y 2 + x 2 y 3 + x 3 y 1 dash.en x 1 y 3 dash.en x 2 y 1 dash.en x 3 y 2|) / 2 $ ])<eq-area>

#math.equation(block: true, numbering: "(1)", [ $ P e r i m e t e r = sqrt((x 2 - x 1)^2 + (y 2 dash.en y 1)^2) + sqrt((x 3 - x 2)^2 + (y 3 dash.en y 2)^2) + sqrt((x 1 - x 3)^2 + (y 1 dash.en y 3)^2) $ ])<eq-perim>

Each stimuli's area was then averaged by participants. The area metric is in % of the screen area to be able to compare with the consistency across studies using different screen sizes. To account for screen size and spread variability across the datasets and participants, area and perimeter were also calculated on individually normalized x and y coordinates (#emph[z-score];). These methods compute consistency metrics at the stimulus level, the rationale is that consistent responses would show less variability between repetitions. For example, smaller area or perimeter of the triangle formed indicate more variability hence more consistent responses between the three repetitions.

== #emph[Form level:] novel consistency tests
<form-level-novel-consistency-tests>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
For the novel consistency tests, we extracted features at the spatial-form level for each repetition separately. Taking the stimuli as an ordered sequence we can consider them as a geometrical segments (i.e. open geometrical form) and polygons (i.e.~closed geometrical form), similarly as originally described in Galton (#link(<ref-galton1880>)[1880];). The first consistency test extracted from the segments is self-intersection. We considered the spatial-forms as a segment constituted by the lines connecting consecutive stimuli separately for each category and repetitions (i.e. Monday (repetition 1) `→` Tuesday (repetition 1) `→` Wednesday (repetition 1), ect) and then counted the number of times each segment self-intersect. The rationale is that SSS should have less chance to produce that self-intersect than control. The number of self-intersections were computed separately for each repetitions and conditions and averaged per participants.

Second, we harnessed a geospatial analysis, the 'sf' package version 1.0.21 (#link(<ref-sf>)[Pebesma & Bivand, 2023];) to extract polyons and geometry-based features from participant's 2D (x,y) coordinate responses. This package allows, for example, to build and analyse segments or polygons and then extract multiple geometrical descriptors or features. Informed by the ordinality of the stimulus, we defined segments and polygon by conditions and repetitions. The rationale here was to determine whether, when considering the spatial-forms formed by stimuli as ordered coordinates (i.e.~as segments or polygon) they remain consistent #emph[between] repetitions for each individuals. We extracted the topological validity, topological simplicity and a compactness score for each polygons (i.e.~3 conditions X 3 repetitions: 9 polygons per participants.

=== Topological validity
<topological-validity>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
We assessed topological validity using geometric validation test. Topological validity tests if a polygons is well-formed and valid according to the Open Geospatial Consortium (OGC) Simple Features Specification (#link(<ref-herring2010>)[Herring, 2010];). A polygon is considered topologically valid if it satisfies the following criteria: (1) if polygon rings are simple (i.e., they do not touch or self-intersect), (2) boundary rings to not cross (3) boundary rings may only touch points tangentially (4) rings that define holes are contained within the exterior ring (5) the polygon rings must not splits the polygon (#link(<ref-postgis>)[#emph[PostGIS 3.6.2dev Manual];, n.d.];).

For each participant we tested for topological validity across individual 3 categories (weekdays, month and numbers) and 3 repetitions, hence 9 forms. The binary outcome (1 = is valid, 0 = invalid) was then averaged across all 9 forms. Hence, it can span from 1 (all 9 are valid) to 0 (none of the 9 forms are valid). Thus, the topological validity score ranges from 0 (none of the nine forms are valid) to 1 (all nine forms are valid). For example, if a participant's forms for weekdays were valid across all three repetitions, months were valid in two of three repetitions, and numbers were invalid in all repetitions, the topological validity score would be 5/9 ≈ 0.56.

=== Topological simplicity
<topological-simplicity>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
We assessed topological simplicity, which evaluates whether a geometric object has a simple structure without self-intersections or self-tangencies. According to the OGC Simple Features Specification (#link(<ref-herring2010>)[Herring, 2010];), a polygon boundary is considered simple if it does not pass through the same point more than once (#link(<ref-postgis>)[#emph[PostGIS 3.6.2dev Manual];, n.d.];). For polygons, simplicity requires that each ring does not self-intersect or self-touch. Note that simplicity is a condition for validity: a polygon can be simple but still invalid (e.g., if an interior ring extends outside the exterior ring).

=== Compactness score
<compactness-score>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Finally, we also implemented a measure of compactness for the space-forms. We used the score developed to quantify the gerrymandering of political district by Polsby and Popper (#link(<ref-polsby1991>)[1991];). Gerrymandering is a politically motivated strategy of redefining district's boundary to give the advantage to a political party. This has the consequences to reduce the compactness of those districts as would be expected if they where defined from geomorphology. The compactness is calculated as the ratio of the area and perimeter of a polygon. The rationale is that more compact forms (i.e.~higher Polsby--Popper scores) would be more likely in SSS than controls. Formally, the Polsby--Popper score is calculated from the polygon's area and perimeter #ref(<eq-PP>, supplement: [Equation]):

#math.equation(block: true, numbering: "(1)", [ $ s c o r e = frac(4 pi dot.op A r e a, P e r i m e t e r^2) $ ])<eq-PP>

=== Permutation-based feature extraction
<permutation-based-feature-extraction>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
On the other hand, we implemented permutations of the repetition order to derive a permuted measure of consistency. Specifically, instead of using repetitions in chronological order, we shuffled the repetition order between stimulus presentation (i.e.~Monday (repetition 2) `→` Tuesday (repetition 3) `→` Wednesday (repetition 1), ect) and extracted the geometrical feature from x,y coordinates of same stimulus categories in non-chronological order The form-based features computed before were relying on the chronologically ordered repetitions. For example, when a stimulus such as Monday was repeated three times, the coordinates for the first presentation of Monday were always paired with the coordinates for the first presentation of Tuesday to construct segments or polygons. However, if synesthetic forms are truly consistent, they should remain stable independently of the chronological order of stimulus presentation. Hence, we permute the repetitions within each condition. Specifically, for each participant and each category, we randomized the response repetition order. For example segments for weekdays were constructed with the x,y coordinates where randomly permuted across repetition order, for example Monday (repetition 1), Tuesday (repetition 3), Wednesday (repetition 2), ect. We predicted that this permuted-based consistency would yield to better classification performance (higher AUC values) compared to chronologically ordered features. The rationale is that genuine synaesthetes would have consistent topological features of spatial-forms repetitions regardless of presentation order, whereas controls would show random variation.

== Receiver Operator Characteristic analyses
<receiver-operator-characteristic-analyses>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Each feature's performance in classifying SSS from controls was compared with Receiver Operator Characteristics (ROC) analyses. Classification performance was quantified using the area under the curve (AUC), with higher AUC values indicating better discrimination between SSS and control groups. The optimal cutoffs were calculated using Youden's index(#link(<ref-youden1950>)[Youden, 1950];). Discriminant Power (DP) was used as an additional estimate of discrimination performance according to the optimal cutoff (#ref(<eq-DP>, supplement: [Equation])). DP around 1 being interpreted as inefficient discrimination.

#math.equation(block: true, numbering: "(1)", [ $ D P = sqrt(3) / pi (log (frac(s e n s i t i v i t y, 1 - s e n s i t i v i t y)) + log (frac(s p e c i f i c i t y, (1 - s p e c i f i c i t y)))) $ ])<eq-DP>

The statistical comparison of ROC curves was operated testing the difference of AUC between pairs of curves using bootstrapping method (1000 times) since it allows to compare methods with different directions. Each bootstrap results in the subtraction of the AUC between the two ROC. Then the each of the AUC difference's (D) are divided by the standard deviation of those difference and compared to a normal distribution (#ref(<eq-D>, supplement: [Equation])).

#math.equation(block: true, numbering: "(1)", [ $ D = frac(A U C_1 - A U C_2, S D) $ ])<eq-D>

Therefore we statistically compared all the AUC of each methods to the difference with the method with the highest AUC.

= Results
<sec-results>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Descriptively, the triangle area (in % screen size) between repetition for SSS was surprisingly larger than in previous studies: 0.26% (#emph[SD = 0.52%];) compared to 0.15% (#emph[SD = 0.13 %];) in Rothen et al. (#link(<ref-rothen2016>)[2016a];) and 0.14 % (#emph[SD = 0.17];) % in Ward et al. (#link(<ref-ward2018>)[2018];), see #link(<tbl-mytb04>)[Table~4];. These values also differ between the available datasets (See #link(<fig-apx08>)[Figure~B2];). These differences could be mitigated by using individually standardized coordinates M = 0.05 (#emph[SD = 0.06];) Rothen et al. (#link(<ref-rothen2016>)[2016a];), M = 0.08 (#emph[SD = 0.15];) Ward (#link(<ref-ward2022a>)[2022];), M = 0.09 (#emph[SD = 0.15];), Ward2, see also #link(<tbl-mytb04>)[Table~4];.

== ROC analyses
<roc-analyses>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Interestingly, while the permuted validity leads to significantly larger AUC than the Polsby-Popper method, (#emph[D] = 2.12 , #emph[p] \< .05, it led to similar AUC than the standardized perimeter (#emph[D] = 1.43, #emph[p] \< .05). All ROC are compared to the permuted validity method, since it led the highest AUC (81.16), all p-values false discovery rate (FDR) adjusted. ROC analyses are summarized in #link(<tbl-mytb03>)[Table~3] and #link(<fig-myplot2>)[Figure~3];.

Furthermore, the permuted validity led to significantly higher AUC than the non permuted one (D = 3.13, #emph[p] \< .05). Hence the two best AUC performances are from the averaged permuted validity score (AUC = 81.16; DP = 2.13, cut-off = 0.17 corresponding to 1.53 valid of 9 forms) and the other for standardized perimeter between the repetitions of each stimuli (AUC = 78.8; DP = 2.06, cut-off = 1.73 z-scores). However, at the proposed cut-off, the permuted validity leads to higher specificity than perimeter (78.55 vs. 75.78) indicating better rejection of controls (i.e.~less false negatives) but lower sensitivity (70.78 vs. 72.54), indicating poorer detection of SSS (i.e.~more false negatives). See #link(<fig-apx01>)[Figure~A1] for the densities of each standardized features suggesting bi-modal distribution.

Some of the participants might have been originally mis-attributed to control or SSS, see #link(<fig-myplotapx07>)[Figure~F1];. Descriptively, we also found about \~6 % of the full sample's synesthetes to be consistently classified as controls (i.e.~consistent false positive) by the five methods with the highest AUC #link(<fig-myplotapx08>)[Figure~F2];. \~3 % controls are consistently classified as SSS (i.e.~consistent false negative) #link(<fig-myplotapx09>)[Figure~F3];.

In sum, the permuted validity and perimeter both provide similarly best AUC compared to the other features. While the permuted validity is best to have fewer false positives (i.e.~controls) while perimeter is best for fewer false negatives (i.e.~SSS).

== Further analyses
<further-analyses>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
We conducted further analyses by subsampling them based on the dataset source, questionnaire percentiles. The aim of these analyses was to test the stability of the classifications from different methods across experiments (i.e.~datasets) and sample characteristics (i.e. questionnaire scores). We also used a correlational approach to test for correlations between features and questionnaires.

We sub-sampled the data based on the source of the data and found different features best fit different datasets, see #link(<fig-myplotapx02>)[Figure~B1];. Interestingly the best features by datasets differ between the data sources. While the standardized area indeed lead to the best AUC for the data from Rothen et al. (#link(<ref-rothen2016>)[2016a];), the perimeter leads to better AUC in Ward et al. (#link(<ref-ward2018>)[2018];). The permuted validity leads to AUC \> 80 across all datasets.

To test the stability of AUC of all features, we computed them across several percentiles based on the questionnaire scores. Again, only the data from Professor Ward is included there. We computed AUC, sensitivity and sensibility on sub samples based on the percentiles of the questionnaire scores (see #link(<ref-ward2018>)[Ward et al., 2018];), taking the 10-0% highest questionnaire scores against the 10 % worst (i.e.~90-100 %) . We further sub-sampled by 10 % questionnaire scores and recalculated AUC, sensitivity and sensibility, see #link(<fig-myplotapx03>)[Figure~C1] for AUC, DP, sensitivity and specificity. Using this method we can see that the total AUC remains relatively stable across percentiles.

Another important point addressed in the literature about consistency test is circularity. The circularity is given in that if consistency tests are used to classify SSS and controls, then those groups will by definition differ in consistency (#link(<ref-root2025>)[Root et al., 2025];). Hence, we made a correlation matrix with the questionnaire scores and all the features, see Appendix. The two highest correlations are indeed between the questionnaire score and perimeter (r = .58) and permuted validity (r = .50), see #link(<fig-myplotapx04>)[Figure~D1];.

We also wanted to visualize the average space form of each category at the population level to see if there were qualitative differences between the forms. The figure in the appendix (#link(<fig-myplotapx06>)[Figure~E1];), shows more circular patterns for months and more linear horizontal and vertical for numbers.

= #emph[Phase II] Methods
<sec-phase-ii-methods>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Additional data will be collected in the future using the same consistency test, with the procedural exception that there will be four repetitions per stimuli instead of three ( Sachdeva et al. (#link(<ref-sachdeva2024>)[2024];), Stage 1 in-principle acceptance). The same feature will be extracted from this dataset. Hence for the stimulus levels feature we will compare the area and perimeter of a rectangle of four coordinates pairs instead of a triangle. Materials are more details on this study are pre-registered on OSF , including ample size and recruitment method (#link(<ref-sachdeva2024>)[Sachdeva et al., 2024];, Stage 1 in-principle acceptance) (#link("https://osf.io/6wn4m");).

We will compute the same ROC analyses as in this pre-registration on all the features. Since we obtain different best AUC per features depending on the dataset (see #link(<fig-myplotapx02>)[Figure~B1];) it is likely that the best features here will not match with the best feature in the to be collected dataset.

= #emph[Phase I.] Discussion
<phase-i.-discussion>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Our investigation of four datasets found two main features leading to the optimal classification of SSS from control: standardized perimeter between repetitions and permuted topological validity. While perimeter is calculated on the stimulus level, i.e.~distance between repeated stimuli, topological validity is calculated on the whole spatial-form level, e.g.~x,y coordinates formed by Monday to Sunday. Both criteria display bimodal distributions across the groups (see #link(<fig-apx01>)[Figure~A1];). We also obtain variable best features by datasets, in particular from the stimulus based metrics (area and perimeter), while topological validity lead to \> 80 AUC across datasets. Considering only the data by Professor Ward that contains questionnaire data, we obtain similar AUC and DP for more extreme Synaesthete and Control groups when sub-sampled by questionnaire's score distribution percentiles (see #link(<fig-myplotapx03>)[Figure~C1];). However, perimeter lead to slightly higher correlation with the questionnaire (r = .57) than permuted topological validity (r = .51), see #link(<fig-myplotapx04>)[Figure~D1];.

== Limitations
<sec-limitations>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Although an optimal test to classify SSS might be particularly relevant for experimental purposes, several important limitations need to be considered. First, consistency tests contain only a limited set of sequential stimuli (i.e.~months, weeks and the first ten natural numbers) that could potentially elicit synaesthetic experiences. Other ordinal categories such as temperature, clock time, musical keys might be more relevant for some individuals with SSS. For numbers specifically, better consistency tests might be obtained using a larger set size (i.e.~including decades and hundreds), as descriptively interesting form changes occur at different decimals in base-10 number systems (#link(<ref-galton1880>)[Galton, 1880];).

Second, the use of diagnostic cutoffs assumes categorical distinctions between groups, but SSS may exist on a continuum and scores might be more suitable (#link(<ref-price2013>)[Price & Pearson, 2013];). This limitation is related to the circularity mentioned previously: diagnostic cutoffs as calculated here depend on how SSS and controls are classified in the first place (#link(<ref-simner2012>)[Simner, 2012];). Measures of other characteristics of synaesthesia such as automaticity or visual Gabor detection might be necessary to establish external validity (#link(<ref-ward2018>)[Ward et al., 2018];). Indeed, determining the prevalence of SSS in the general population requires definitional choices that might be base on more conservative or lenient criteria (#link(<ref-brang2010>)[Brang et al., 2010];; #link(<ref-jonas2014>)[Jonas & Price, 2014];; #link(<ref-sagiv2006>)[Sagiv et al., 2006];; #link(<ref-ward2018>)[Ward et al., 2018];). These difficulties are reflected in the span of current prevalence estimates: 4.4 % (#link(<ref-brang2013>)[Brang et al., 2013];), 8.1 % (#link(<ref-ward2018>)[Ward et al., 2018];) and 14 % (#link(<ref-seron1992>)[Seron et al., 1992];).

Third, as shown in #link(<fig-myplotapx02>)[Figure~B1];, we find that the optimal criteria can vary across datasets. In other word, we obtain different AUC depending on the datasets. These differences might be explained by different sampling methods biases, for example (#link(<ref-vanpetersen2020>)[Van Petersen et al., 2020];) recruited SSS from over one hundred candidates to maximise participant reporting synesthetic experiences. Additionally, the original classification into control and SSS are not consistent across studies and it might be useful to have several validation measures as pointed out in the limitation (see #link(<ref-ward2018>)[Ward et al., 2018];).

Another possible explanation may be methodological and related to the option to skip responses in the task, leaving empty cases for some participants. Indeed, having fewer responses (i.e., fewer coordinates) increases the likelihood of producing a valid spatial form also in controls. Conversely, perimeter and area are differentially affected by missing responses.

== Topological validity
<topological-validity-1>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Surprisingly, permuted topological validity of the spatial-forms led to similar results than the perimeter (or the distance) between the responses. This result might be informative about how SSS map ordinal stimuli in space. Indeed, it seems the patterns of spatial-forms follow topological rules analogous to geographical and geometry-based space structures. Analogies between maps and neuroscience have a long history (i.e.~retinotopy, sonotopy or somatotopy) (#link(<ref-eagleman2009>)[Eagleman & Goodale, 2009];). Therefore spatial-forms might originate from the mapping between ordinal or sequential stimuli on idiosyncratic visuo-spatial abilities following topological rules. One of the advantages of using topological validity is that it also classifies responses with the same coordinates as invalid and hence inconsistent, while using the area and perimeter metrics they would qualify as highly consistent responses.

== Intermediary Conclusion
<sec-conclusions>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
#emph[Phase I] compared traditional stimulus-level consistency measures with novel form-level geometric features for detecting SSS. We found optimal classification performance from permuted topological validity and standardized perimeter between repetitions. The success of topological validity as a diagnostic feature is theoretically meaningful: genuine synesthetes should produce spatially coherent, well-formed structures that satisfy geometric constraints compared to controls. Similarly, the perimeter feature captures the stability of the overall spatial configuration across repetitions, which should remain consistent for true SSS individuals regardless of presentation order.

In #emph[phase II,] we will attempt at validating the criteria on a yet-to be acquired dataset.

= References
<references>
#set par(first-line-indent: 0in, hanging-indent: 0.5in)
#block[
#block[
Baron-Cohen, S., Harrison, J., Goldstein, L. H., & Wyke, M. (1993). Coloured Speech Perception: Is Synaesthesia what Happens when Modularity Breaks Down? #emph[Perception];, #emph[22];(4), 419--426. #link("https://doi.org/10.1068/p220419")

] <ref-baron-cohen1993>
#block[
Brang, D., Miller, L. E., McQuire, M., Ramachandran, V. S., & Coulson, S. (2013). Enhanced mental rotation ability in time-space synesthesia. #emph[Cognitive Processing];, #emph[14];(4), 429--434. #link("https://doi.org/10.1007/s10339-013-0561-5")

] <ref-brang2013>
#block[
Brang, D., Teuscher, U., Ramachandran, V. S., & Coulson, S. (2010). Temporal sequences, synesthetic mappings, and cultural biases: The geography of time. #emph[Consciousness and Cognition];, #emph[19];(1), 311--320. #link("https://doi.org/10.1016/j.concog.2010.01.003")

] <ref-brang2010>
#block[
Brunson, J. C., & Read, Q. D. (2023). #emph[ggalluvial: Alluvial plots in 'ggplot2'];. #link("http://corybrunson.github.io/ggalluvial/")

] <ref-ggalluvial>
#block[
Deroy, O., & Spence, C. (2013). Why we are not all synesthetes (not even weakly so). #emph[Psychonomic Bulletin & Review];, #emph[20];(4), 643--664. #link("https://doi.org/10.3758/s13423-013-0387-2")

] <ref-deroy2013>
#block[
Dixon, M. J., Smilek, D., & Merikle, P. M. (2004). Not all synaesthetes are created equal: Projector versus associator synaesthetes. #emph[Cognitive, Affective, & Behavioral Neuroscience];, #emph[4];(3), 335--343. #link("https://doi.org/10.3758/CABN.4.3.335")

] <ref-dixon2004>
#block[
Eagleman, D. M. (2009). The objectification of overlearned sequences: A new view of spatial sequence synesthesia. #emph[Cortex];, #emph[45];(10), 1266--1277. #link("https://doi.org/10.1016/j.cortex.2009.06.012")

] <ref-eagleman2009a>
#block[
Eagleman, D. M., & Goodale, M. A. (2009). Why color synesthesia involves more than color. #emph[Trends in Cognitive Sciences];, #emph[13];(7), 288--292. #link("https://doi.org/10.1016/j.tics.2009.03.009")

] <ref-eagleman2009>
#block[
Flournoy, T. (1893). #emph[Des phénomènes de synopsie (audition colorée): Photismes, schèmes visuels, personnifications];. Alcan. #link("https://books.google.bj/books?id=JISQxpcyGUMC")

] <ref-flournoy1893>
#block[
Galton, F. (1880). Visualised Numerals. #emph[Nature];, #emph[21];(533), 252--256. #link("https://doi.org/10.1038/021252a0")

] <ref-galton1880>
#block[
Gao, C.-H., & Dusa, A. (2025). #emph[ggVennDiagram: A 'ggplot2' implement of venn diagram];. #link("https://github.com/gaospecial/ggVennDiagram")

] <ref-ggVennDiagram>
#block[
Gould, C., Froese, T., Barrett, A. B., Ward, J., & Seth, A. K. (2014). An extended case study on the phenomenology of sequence-space synesthesia. #emph[Frontiers in Human Neuroscience];, #emph[8];. #link("https://doi.org/10.3389/fnhum.2014.00433")

] <ref-gould2014>
#block[
Herring, J. R. (2010). #emph[OpenGIS® Implementation Standard for Geographic information - Simple feature access - Part 1: Common architecture];.

] <ref-herring2010>
#block[
Jarick, M., Dixon, M. J., Stewart, M. T., Maxwell, E. C., & Smilek, D. (2009). A different outlook on time: Visual and auditory month names elicit different mental vantage points for a time-space synaesthete. #emph[Cortex];, #emph[45];(10), 1217--1228. #link("https://doi.org/10.1016/j.cortex.2009.05.014")

] <ref-jarick2009>
#block[
Jonas, C. N., & Price, M. C. (2014). Not all synesthetes are alike: Spatial vs. Visual dimensions of sequence-space synesthesia. #emph[Frontiers in Psychology];, #emph[5];. #link("https://doi.org/10.3389/fpsyg.2014.01171")

] <ref-jonas2014>
#block[
Lyons, I. M., & Beilock, S. L. (2013). Ordinality and the Nature of Symbolic Numbers. #emph[The Journal of Neuroscience];, #emph[33];(43), 17052--17061. #link("https://doi.org/10.1523/JNEUROSCI.1775-13.2013")

] <ref-lyons2013>
#block[
Pebesma, E., & Bivand, R. (2023). #emph[Spatial Data Science: With applications in R];. Chapman and Hall/CRC. #link("https://doi.org/10.1201/9780429459016")

] <ref-sf>
#block[
Polsby, D. D., & Popper, R. (1991). The Third Criterion: Compactness as a Procedural Safeguard Against Partisan Gerrymandering. #emph[SSRN Electronic Journal];. #link("https://doi.org/10.2139/ssrn.2936284")

] <ref-polsby1991>
#block[
#emph[PostGIS 3.6.2dev manual];. (n.d.).

] <ref-postgis>
#block[
Price, M., & Pearson, D. (2013). Toward a visuospatial developmental account of sequence-space synesthesia. #emph[Frontiers in Human Neuroscience];, #emph[7];. #link("https://doi.org/10.3389/fnhum.2013.00689")

] <ref-price2013>
#block[
Robin, X., Turck, N., Hainard, A., Tiberti, N., Lisacek, F., Sanchez, J.-C., & Müller, M. (2011). pROC: An open-source package for R and S+ to analyze and compare ROC curves. #emph[BMC Bioinformatics];, #emph[12];, 77.

] <ref-pROC>
#block[
Root, N., Asano, M., Melero, H., Kim, C.-Y., Sidoroff-Dorso, A. V., Vatakis, A., Yokosawa, K., Ramachandran, V., & Rouw, R. (2021). Do the colors of your letters depend on your language? Language-dependent and universal influences on grapheme-color synesthesia in seven languages. #emph[Consciousness and Cognition];, #emph[95];, 103192. #link("https://doi.org/10.1016/j.concog.2021.103192")

] <ref-root2021>
#block[
Root, N., Chkhaidze, A., Melero, H., Sidoroff-Dorso, A., Volberg, G., Zhang, Y., & Rouw, R. (2025). How “diagnostic” criteria interact to shape synesthetic behavior: The role of self-report and testretest consistency in synesthesia research. #emph[Consciousness and Cognition];, #emph[129];, 103819. #link("https://doi.org/10.1016/j.concog.2025.103819")

] <ref-root2025>
#block[
Rothen, N., Jünemann, K., Mealor, A. D., Burckhardt, V., & Ward, J. (2016a). The sensitivity and specificity of a diagnostic test of sequence-space synesthesia. #emph[Behavior Research Methods];, #emph[48];(4), 1476--1481. #link("https://doi.org/10.3758/s13428-015-0656-2")

] <ref-rothen2016>
#block[
Rothen, N., Jünemann, K., Mealor, A. D., Burckhardt, V., & Ward, J. (2016b). The sensitivity and specificity of a diagnostic test of sequence-space synesthesia. #emph[Behavior Research Methods];, #emph[48];(4), 1476--1481. #link("https://doi.org/10.3758/s13428-015-0656-2")

] <ref-rothen2016a>
#block[
Rothen, N., Seth, A. K., Witzel, C., & Ward, J. (2013). Diagnosing synaesthesia with online colour pickers: Maximising sensitivity and specificity. #emph[Journal of Neuroscience Methods];, #emph[215];(1), 156--160. #link("https://doi.org/10.1016/j.jneumeth.2013.02.009")

] <ref-rothen2013a>
#block[
Sachdeva, C., Whelan, E., Ovalle-Fresa, R., Rey-Mermet, A., Ward, J., & Rothen, N. (2024). #emph[How perceptual ability shapes memory: An investigation in healthy special populations];. #link("https://osf.io/6wn4m")

] <ref-sachdeva2024>
#block[
Sagiv, N., Simner, J., Collins, J., Butterworth, B., & Ward, J. (2006). What is the relationship between synaesthesia and visuo-spatial number forms? #emph[Cognition];, #emph[101];(1), 114--128. #link("https://doi.org/10.1016/j.cognition.2005.09.004")

] <ref-sagiv2006>
#block[
Seron, X., Pesenti, M., Noël, M.-P., Deloche, G., & Cornet, J.-A. (1992). Images of numbers, or “when 98 is upper left and 6 sky blue”. #emph[Cognition];, #emph[44];(1), 159--196. #link("https://doi.org/10.1016/0010-0277(92)90053-K")

] <ref-seron1992>
#block[
Simner, J. (2012). Defining synaesthesia. #emph[British Journal of Psychology];, #emph[103];(1), 1--15. #link("https://doi.org/10.1348/000712610X528305")

] <ref-simner2012>
#block[
Smilek, D., Callejas, A., Dixon, M. J., & Merikle, P. M. (2007). Ovals of time: Time-space associations in synaesthesia. #emph[Consciousness and Cognition];, #emph[16];(2), 507--519. #link("https://doi.org/10.1016/j.concog.2006.06.013")

] <ref-smilek2007>
#block[
Van Petersen, E., Altgassen, M., Van Lier, R., & Van Leeuwen, T. M. (2020). Enhanced spatial navigation skills in sequence-space synesthetes. #emph[Cortex];, #emph[130];, 49--63. #link("https://doi.org/10.1016/j.cortex.2020.04.034")

] <ref-vanpetersen2020>
#block[
Ward, J. (2022). #emph[Optimizing a measure of consistency for sequence-space synaesthesia];. #link("https://osf.io/5cnr7_v1")

] <ref-ward2022a>
#block[
Ward, J., Ipser, A., Phanvanova, E., Brown, P., Bunte, I., & Simner, J. (2018). The prevalence and cognitive profile of sequence-space synaesthesia. #emph[Consciousness and Cognition];, #emph[61];, 79--93. #link("https://doi.org/10.1016/j.concog.2018.03.012")

] <ref-ward2018>
#block[
Ward, J., & Simner, J. (2022). How do Different Types of Synesthesia Cluster Together? Implications for Causal Mechanisms. #emph[Perception];, #emph[51];(2), 91--113. #link("https://doi.org/10.1177/03010066211070761")

] <ref-ward2022>
#block[
Wei, T., & Simko, V. (2024). #emph[R package 'corrplot': Visualization of a correlation matrix];. #link("https://github.com/taiyun/corrplot")

] <ref-corrplot>
#block[
Wickham, H. (2016). #emph[ggplot2: Elegant graphics for data analysis];. Springer-Verlag New York. #link("https://ggplot2.tidyverse.org")

] <ref-ggplot2>
#block[
Wilke, C. O. (2025a). #emph[cowplot: Streamlined plot theme and plot annotations for 'ggplot2'];. #link("https://doi.org/10.32614/CRAN.package.cowplot")

] <ref-cowplot>
#block[
Wilke, C. O. (2025b). #emph[ggridges: Ridgeline plots in 'ggplot2'];. #link("https://doi.org/10.32614/CRAN.package.ggridges")

] <ref-ggridges>
#block[
Youden, W. J. (1950). Index for rating diagnostic tests. #emph[Cancer];, #emph[3];(1), 32--35. #link("https://doi.org/10.1002/1097-0142(1950)3:1<32::aid-cncr2820030106>3.0.co;2-3")

] <ref-youden1950>
] <refs>
#set par(first-line-indent: 0.5in, hanging-indent: 0in)
#pagebreak()
=== Appendix
<appendix>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
The additional analyses in this appendix attempt to address several concerns. Regarding the distribution's of the scores from the different methods, i.e.~whether it is bimodal, see #link(<apx-featDensity>)[Appendix~A];. Then to visualize the stability of the ROC analyses across the datasets, i.e. whether AUC, DP, sensitivity and specificity vary across the four different datasets, see #link(<apx-SM2byds>)[Appendix~B];.

To address circularity concerns that we might find methods that best classifies synesthetes and controls only from the sed on self-reported groups, we attempted two additional approaches: first, testing sub-samples based on percentiles of the questionnaire score sample distribution (see #link(<apx-byquestperc>)[Appendix~C];). The rationale is that a good consistency test should have similar discriminative performance for strong SSS and weaker SSS. To do this, we re-sampled the SSS and controls based on their questionnaire distribution by percentiles (i.e., comparing 10% highest questionnaire scores vs.~10% lowest, then 20% vs.~20%, etc.). In addition, we correlated the questionnaire scores with the results from different features extracted from the consistency test, see #link(<apx-correlation-with-self-report>)[Appendix~D];.

We also wanted to visually characterize whether certain patterns occur more frequently for some categories than others (i.e.~circular pattern for months and linear for numbers). #link(<apx-average-forms>)[Appendix~E] shows the average forms for each categories. Finally, we wanted to visualize how each participant is classified by each test. From this we found a group of Synaesthetic who consistently are classified as controls by different methods as well as a group of control who are consistently classified as synaesthetes, see #link(<apx-alluvial>)[Appendix~F];.

The following R packages were used for the data visualization in the appendix: 'ggridges' v. 0.5.7 (#link(<ref-ggridges>)[Wilke, 2025b];), 'cowplot' v. 1.2.0 (#link(<ref-cowplot>)[Wilke, 2025a];), 'ggalluvial' v. 0.12.5 (#link(<ref-ggalluvial>)[Brunson & Read, 2023];), 'corrplot' v. 0.95 (#link(<ref-corrplot>)[Wei & Simko, 2024];)

#pagebreak(weak: true)
#figure([
#table(
  columns: 4,
  align: (auto,auto,auto,auto,),
  table.header([Synaesthetes], [N before], [N after], [Age],),
  table.hline(),
  [(#link(<ref-rothen2016>)[Rothen et al., 2016a];)], [33], [32], [23.1],
  [(#link(<ref-vanpetersen2020>)[Van Petersen et al., 2020];)], [23], [22], [23.2],
  [(#link(<ref-ward2022a>)[Ward, 2022];)], [252], [252], [37.2],
  [Ward 2], [90], [90], [NA],
  [Total:], [398], [396], [],
)
], caption: figure.caption(
position: top, 
[
Synesthetes
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-mytable01>


#pagebreak(weak: true)
#figure([
#table(
  columns: 4,
  align: (auto,auto,auto,auto,),
  table.header([Controls], [N before], [N after], [Age],),
  table.hline(),
  [(#link(<ref-rothen2016>)[Rothen et al., 2016a];)], [37], [37], [28.2],
  [(#link(<ref-vanpetersen2020>)[Van Petersen et al., 2020];)], [21], [21], [21.6],
  [(#link(<ref-ward2022a>)[Ward, 2022];)], [215], [213], [19.9],
  [Ward 2], [18], [18], [NA],
  [Total], [291], [289], [],
)
], caption: figure.caption(
position: top, 
[
Controls
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-mytable02>


#pagebreak(weak: true)
#figure([
#table(
  columns: (3.53%, 43.53%, 7.06%, 5.88%, 11.76%, 14.12%, 14.12%),
  align: (left,left,right,right,right,right,right,),
  table.header([], [Feature], [AUC], [DP], [threshold], [sensitivity], [specificity],),
  table.hline(),
  [10], [Permuted valid structure \[boolean/9\]], [81.16], [2.13], [0.17], [70.78], [78.55],
  [11], [Polsby--Popper \[score/9\]], [78.89], [2.29], [0.19], [59.70], [87.54],
  [4], [Perimeter \[z-score\]], [78.80], [2.06], [1.73], [72.54], [75.78],
  [9], [Valid structure \[boolean/9\]], [78.12], [1.90], [0.14], [72.80], [72.32],
  [12], [Permuted P-P \[score/9\]], [77.15], [2.46], [0.20], [57.18], [90.31],
  [5], [Segment self-intersections \[n/9\]], [72.93], [1.75], [1.17], [79.85], [60.21],
  [6], [Area of the polygon \[z-score\]], [72.03], [1.36], [1.29], [64.99], [68.51],
  [8], [Simple topology \[boolean/9\]], [69.74], [1.24], [0.28], [61.96], [68.51],
  [2], [Area \[z-score\]], [69.27], [1.68], [0.08], [76.32], [63.32],
  [7], [Perimeter of the polygon \[z-score\]], [59.12], [1.29], [10.46], [83.88], [41.87],
  [3], [Perimeter \[screen size %\]], [55.34], [0.68], [0.03], [76.07], [38.75],
  [1], [Area \[screen size %\]], [50.87], [0.79], [0.21], [76.83], [40.48],
)
], caption: figure.caption(
position: top, 
[
ROC analyses of all features
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-mytb03>


#pagebreak(weak: true)
#figure([
#table(
  columns: (42.05%, 14.77%, 13.64%, 14.77%, 14.77%),
  align: (left,left,left,left,left,),
  table.header([Feature], [Control], [SSS], [Control \[zs\]], [SSS \[zs\]],),
  table.hline(),
  [Permuted valid structure \[boolean/9\]], [0.12 (0.16)], [0.36 (0.25)], [-0.57 (0.64)], [0.41 (1.01)],
  [Polsby--Popper \[score/9\]], [0.11 (0.13)], [0.27 (0.19)], [-0.51 (0.69)], [0.37 (1.03)],
  [Perimeter \[z-score\]], [3.30 (1.72)], [1.59 (1.16)], [0.60 (1.04)], [-0.44 (0.70)],
  [Valid structure \[boolean/9\]], [0.13 (0.19)], [0.39 (0.28)], [-0.54 (0.69)], [0.39 (1.01)],
  [Permuted P-P \[score/9\]], [0.11 (0.17)], [0.41 (0.33)], [-0.56 (0.56)], [0.40 (1.06)],
  [Segment self-intersections \[n/9\]], [9.56 (11.31)], [1.87 (5.42)], [0.48 (1.23)], [-0.35 (0.59)],
  [Area of the polygon \[z-score\]], [1.00 (0.99)], [1.91 (1.31)], [-0.42 (0.79)], [0.30 (1.03)],
  [Simple topology \[boolean/9\]], [0.22 (0.23)], [0.40 (0.27)], [-0.39 (0.85)], [0.28 (1.01)],
  [Area \[z-score\]], [0.26 (0.32)], [0.08 (0.14)], [0.42 (1.29)], [-0.30 (0.55)],
  [Perimeter of the polygon \[z-score\]], [9.49 (3.44)], [8.39 (2.48)], [0.21 (1.16)], [-0.16 (0.83)],
  [Perimeter \[screen size %\]], [0.03 (0.03)], [0.03 (0.08)], [0.03 (0.44)], [-0.02 (1.26)],
  [Area \[screen size %\]], [0.46 (0.87)], [0.26 (0.52)], [0.17 (1.25)], [-0.12 (0.75)],
)
], caption: figure.caption(
position: top, 
[
Descriptives of each features
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-mytb04>


#pagebreak(weak: true)
#figure([
#box(image("RPlot02.png"))
], caption: figure.caption(
position: top, 
[
Deisgn for novel method for consistency test: from between trial varibility to Segment and polygons formed by the space-forms using geography tools.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-Ex01>


#pagebreak(weak: true)
#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplot01-1.png"))
], caption: figure.caption(
position: top, 
[
Venn diagram of the types of self-reported SSS
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplot01>


#block[
#block[
#emph[Note];. Only~data from Pr. Ward is represented here. SSS = Sequence-space synaesthesia
]
]
#pagebreak(weak: true)
#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplot2-1.png"))
], caption: figure.caption(
position: top, 
[
Receiver Operating Characteristic (ROC) curves of all features
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplot2>


#block[
#block[
#emph[Note];. Grey~line indicates chance level
]
]
#pagebreak(weak: true)
= Appendix A
#counter(figure.where(kind: "quarto-float-fig")).update(0)
#counter(figure.where(kind: "quarto-float-tbl")).update(0)
#appendixcounter.step()
= Feature distributions
<apx-featDensity>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Regarding the distributions of each features across the SSS vs. controls, #link(<fig-apx01>)[Figure~A1] we compared the density plots of each standardized criteria (in order to make them comparable) which visually suggests bimodal distribution.

#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-apx01-1.png"))
], caption: figure.caption(
position: top, 
[
Density plots of all the features comparing SSS and controls
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-apx01>


#block[
#block[
#emph[Note];. Red~= Classified as Synesthetes, Blue = as controls.
]
#block[
All method's score have been standardized (#emph[z-score];). x axis treamed between -3 and 3 z-scores. Vertical line indicate respectively 25 and 75 percentiles of each distributions.
]
]
#pagebreak(weak: true)
= Appendix B
#counter(figure.where(kind: "quarto-float-fig")).update(0)
#counter(figure.where(kind: "quarto-float-tbl")).update(0)
#appendixcounter.step()
= ROC analysis by dataset
<apx-SM2byds>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Here we compare the ROC analyses results for each data sample of the three methods with the best AUC, see #link(<fig-apx08>)[Figure~B2];. Descriptively, we also looked a the distributions of each methods across SSS and controls #link(<fig-myplotapx02>)[Figure~B1];. Note that the dataset labelled as Ward 2 has more synaesthetes than controls (5:1 ratio).

#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplotapx02-1.png"))
], caption: figure.caption(
position: top, 
[
Lineplots of AUC and DP by data source
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplotapx02>


#block[
#block[
#emph[Note];. AUC~= Area Under the Curve, DP = Discrimination Power
]
]
#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-apx08-1.png"))
], caption: figure.caption(
position: top, 
[
Density plots of all the features comparing SSS and controls by dataset
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-apx08>


#block[
#block[
#emph[Note];. Red~= Classified as Synesthetes, Blue = as controls.
]
#block[
All method's score have been standardized (#emph[z-score];). x axis treamed between -3 and 3 z-scores. Vertical line indicate respectively 25 and 75 percentiles of each distributions.
]
]
#pagebreak(weak: true)
= Appendix C
#counter(figure.where(kind: "quarto-float-fig")).update(0)
#counter(figure.where(kind: "quarto-float-tbl")).update(0)
#appendixcounter.step()
= ROC Analysis Sub-sampled data by questionnaire quantiles (20% steps)
<apx-byquestperc>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
We compared the data sampled by the questionnaire score. Based on the distribution of the questionnaire score, we sampled the 10 % with the lowest and 10 % with the highest scores. Those are then compared with the 20 and 20 % and so on until 40 and 40 %. The rationale of this procedure is that AUC, sensitivity and specificity should remain stable across percentiles for a feature to be valid, see #link(<fig-myplotapx03>)[Figure~C1];. In other words the ROC should remain unchanged if we take extreme groups compared to less extreme ones.

#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplotapx03-1.png"))
], caption: figure.caption(
position: top, 
[
Lineplots of AUC and DP by questionnaire percentile
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplotapx03>


#block[
#block[
#emph[Note];. Each~point is an increasing percentiles. AUC = Area Under the Curve. DP = Discrimination Power.
]
]
#pagebreak(weak: true)
= Appendix D
#counter(figure.where(kind: "quarto-float-fig")).update(0)
#counter(figure.where(kind: "quarto-float-tbl")).update(0)
#appendixcounter.step()
= Correlation with self-report
<apx-correlation-with-self-report>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
The best criterion should also best correlate with SSS self-reported questionnaire score. \
Works only with Ward's aggregated data, see #link(<fig-myplotapx04>)[Figure~D1];.

#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplotapx04-1.png"))
], caption: figure.caption(
position: top, 
[
Correlation with self-reported questionnaire
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplotapx04>


#block[
#block[
#emph[Note];. Only~data from Ward is included here
]
]
#pagebreak(weak: true)
= Appendix E
#counter(figure.where(kind: "quarto-float-fig")).update(0)
#counter(figure.where(kind: "quarto-float-tbl")).update(0)
#appendixcounter.step()
= Centred average forms
<apx-average-forms>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
In this additional analyses we attempted at visualizing the average for each categories to see whether a pattern could be discerned on a qualitative level. To avoid negative coordinates, we shifted all the z-scores from the whole dataset minimum for the x and y coordinates. Then we anchored to the coordinate 0,0 the stimulus "1" for numbers, "Monday" for weekdays and "January" for months. We then plotted all the space forms with transparency, see #link(<fig-myplotapx06>)[Figure~E1];.

Descriptively it is possible to see more circular pattern for months and horizontal and vertical patterns for numbers. Also the averaged forms appear to be more clearly defined in the synaesthetes than control.

#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplotapx06-1.png"))
], caption: figure.caption(
position: top, 
[
Average Centered space forms visualized
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplotapx06>


#pagebreak(weak: true)
= Appendix F
#counter(figure.where(kind: "quarto-float-fig")).update(0)
#counter(figure.where(kind: "quarto-float-tbl")).update(0)
#appendixcounter.step()
= Alluvial plot
<apx-alluvial>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Are false positives and negatives share some characteristics? To answer this question qualitatively we identified two group of self-reported SSS participants who care consistently classified as controls by the five methods with the highest AUC (i.e.~consistent false negatives), see dark blue lines in #link(<fig-myplotapx07>)[Figure~F1];. On the other side we identified a group of controls who are consistently classified as SSS by the five methods with the highest AUC, see dark red lines in #link(<fig-myplotapx07>)[Figure~F1] .

#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplotapx07-1.png"))
], caption: figure.caption(
position: top, 
[
Alluvial plot of test passing
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplotapx07>


#block[
#block[
#emph[Note];. Red~= Controls, Blue = Synaesthetes. Highlighted in blue are Synesthetes who are classified as control by all 5 tests. Highlighted in red are controls who are classified as synesthetes by all 5 tests.
]
]
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
On one side 6.12 % of all participants, that is 42 Synaesthetes where consistently classified as controls by all five tests, see #link(<fig-myplotapx08>)[Figure~F2];. On the other side 3.35 % of all participants, 23 controls where consistently classified as SSS by all five tests, see #link(<fig-myplotapx09>)[Figure~F3];. Given the different approaches of each methods, the identified participants might be on one side non-genuine synesthetes and on the other controls who have SSS but are either not aware or did not identify it as such.

#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplotapx08-1.png"))
], caption: figure.caption(
position: top, 
[
Synaesthetes who consistently #emph[fail] all five tests
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplotapx08>


#figure([
#box(image("2.RegisteredReport_MS2_files/figure-typst/fig-myplotapx09-1.png"))
], caption: figure.caption(
position: top, 
[
Controls who consistently #emph[pass] all five tests
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-myplotapx09>


#pagebreak(weak: true)
= Appendix G
#counter(figure.where(kind: "quarto-float-fig")).update(0)
#counter(figure.where(kind: "quarto-float-tbl")).update(0)
#appendixcounter.step()
= Code to visualize all spatial-forms
<apx-code-to-visualize-all-spatial-forms>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
This exports many pdf's. It plots each ID and condition z-score x and y coordinates. Since each coordinate is repeated 3 times, these are represented by triangles. The line paths connect average coordinates to visualize forms (stimulus are ordered, i.e.~1 to 9, Monday to Sunday, January to December). Finally in the top right corner, each dots indicates if the ID would pass (green dot) / fails (red dot) depending on the criteria.

 
  
#set bibliography(style: "\_extensions/wjschne/apaquarto/apa.csl") 


