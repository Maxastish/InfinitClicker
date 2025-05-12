import 'package:clicker/music_player.dart';
import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  final BigInt resources;
  final int currentPhase;  // Добавим переменную для текущей фазы

  AchievementsPage({required this.resources, required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: ListView(
        children: [
          if (currentPhase >= 1)
            _buildNumberDescription(
                "You're a kitty, I'm a kitty",
                "Meow meow meow",
                "So what are you pressing?\nWhat if I press on you?\nScared?\nDon't be scared\nI'm a friend",
                context,
              "nyan_cat",
            ),
          if (currentPhase >= 1)
            _buildNumberDescription(
                "Stage 1: 1, 10, 100, 1.000, 1.000.000, 1.000.000.000.000",
                "You can count on your hands, for example: 1 fish, 2 fish, 3 fish, 10 sextillion fish",
                "Here, numbers are expressed as, strangely enough, numbers, well, you can also use letters. What else did you expect to hear? "
                    "This is the first stage, congratulations! There will be some interesting facts, like in a water drop, there are 12 sextillion molecule!"
                    "To be exact: 1.204 * 10²²",
                context,
              "_fish"
            ),
          if (currentPhase >= 2)
            _buildNumberDescription(
                "Stage 2: 10 ^ 100 (Googol)",
                "Billions of billions, but still within the realm of countable numbers",
                "A googol is 10 ^ 100, a number so large that it exceeds the number of atoms in the observable universe. "
                    "The name 'googol' was coined by a 9-year-old, and it later inspired the name of Google.",
                context,
                "electronomia"
            ),
          if (currentPhase >= 3)
            _buildNumberDescription(
                "Stage 3: 10 ^ 10 ^ 100 (Googolplex)",
                "Having trouble perceiving it? Don't worry, this is just the beginning!",
                "A googolplex is 10 ^ 10 ^ 100, a number so large that even writing it out in full would be physically impossible within the observable universe. "
                    "Carl Sagan once said that if you tried to write a googolplex, you would run out of space in the known universe.",
                context,
              "siiii-ronaldo"
            ),
          if (currentPhase >= 4)
            _buildNumberDescription(
                "Stage 4: 3↑↑↑3 (Tetration of 3)",
                "The power of arrows. We're in a whole different scale now",
                "The Ackermann function grows extremely fast, faster than any primitive recursive function."
                  "The number of arrows is like a replacement for powers, for example 3↑↑↑3 is the same as 3+1 times 3 to the power of 3 (3^3^3^3^3), 4 arrows - 4+1 times and so on.\n"
                    "This number is so massive that it cannot be written even with all the atoms in the universe. "
                    "It grows far faster than exponentiation and enters the realm of hyperoperations.",
                context,
              "villager-what-the-hell"
            ),
          if (currentPhase >= 5)
            _buildNumberDescription(
                "Stage 5: 4↑↑↑100",
                "This is where things get truly insane! Growing exponentially",
                "This number is vastly larger than 3↑↑↑100, showing how fast tetration scales. "
                    "It is part of an extreme number-growing hierarchy used in combinatorics and theoretical math.",
                context,
              "freddy-fazbear"
            ),
          if (currentPhase >= 6)
            _buildNumberDescription(
                "Stage 6: 5↑↑↑100",
                "Each number is its own universe. The bigger, the stranger",
                "The growth rate here is unimaginable—this number is larger than the number of particles in any conceivable universe. "
                    "Numbers of this size have no physical application but are crucial in mathematical logic.",
                context,
              "we-do-a-little-trolling"
            ),
          if (currentPhase >= 7)
            _buildNumberDescription(
                "Stage 7: 100↑↑↑100",
                "It's almost beyond comprehension. A true escape from normal limits!",
                "Numbers generated from operations like "
                    "This number is beyond the scale of any written notation—it is so large that it makes a googolplex look tiny. "
                    "It is an example of how large numbers in pure mathematics go beyond practical use.",
                context,
              "mood"
            ),
          if (currentPhase >= 8)
            _buildNumberDescription(
                "Stage 8: G64 (Graham's number)",
                "Graphs and hyper-operations, watch as numbers lose all meaning",
                "What if we could write even more arrows? Then we could use the notation g_n, where n is the number of arrows + 3. "
                    "Graham's number (64 + 3 arrows) is so large that even if we wrote all the digits in a tiny font, "
                    "the number would still not fit in the observable universe. "
                    "It is used in a problem related to the upper bound in Ramsey theory.",
                context,
              "chipi-chapa"
            ),
          if (currentPhase >= 9)
            _buildNumberDescription(
                "Stage 9: ∞",
                "To infinity and beyond! Buzz Lightyear",
                "Infinity is not a number but a concept that describes something without a limit. "
                    "Mathematicians classify different types of infinity, some larger than others, such as countable and uncountable infinity.",
                context,
              "_9"
            ),
          if (currentPhase >= 10)
            _buildNumberDescription(
                "Stage 10: ω + 1",
                "Ordinal Omega, just adding a little more. But it's only the beginning!",
                "Omega is the smallest infinite ordinal number. "
                    "It represents the order type of the natural numbers.",
                context,
              "all_star"
            ),
          if (currentPhase >= 11)
            _buildNumberDescription(
                "Stage 11: ω ∗ 10",
                "Forget everything you knew about multiplication. This is a new level",
                "Unlike standard multiplication, multiplying ω by a finite number does not change its infinity but rather its structure. "
                    "ω * 10 represents an ordered sequence of 10 infinite sets.",
                context,
              "pokemon-german"
            ),
          if (currentPhase >= 12)
            _buildNumberDescription(
                "Stage 12: ω ^ 100",
                "Omega raised to a power. Again. And again. Infinity multiplies.",
                "Raising an ordinal to a power creates an even more complex structure, involving higher levels of infinity. "
                    "Ordinal exponentiation is a crucial part of set theory and is far more complex than regular exponentiation.",
                context,
              "arabic-nokia"
            ),
          if (currentPhase >= 13)
            _buildNumberDescription(
                "Stage 13: ω100(↑)ω",
                "Ordinal complexities begin to grow exponentially.",
                "This notation represents an incredibly fast-growing sequence. "
                    "It surpasses standard mathematical operations and enters the realm of transfinite arithmetic.",
                context,
              "disturbing-the-peace"
            ),
          if (currentPhase >= 14)
            _buildNumberDescription(
                "Stage 14: ε0 + 1",
                "The power of ε0 is not fully unleashed yet.",
                "ε0 is the smallest solution to the equation ω ^ x = x, making it a fundamental milestone in ordinal arithmetic. "
                    "It plays a key role in proof theory, especially in the study of Peano arithmetic and its consistency.",
                context,
              "freebird"
            ),
          if (currentPhase >= 15)
            _buildNumberDescription(
                "Stage 15: ω ^ ε0 ∗ 10",
                "Where Omega meets ε0, the magic begins",
                "ω ^ ε0 is an ordinal even larger than ε0 and is used to measure the strength of mathematical induction. "
                    "It continues the hierarchy of transfinite numbers, forming a foundation for more advanced ordinal calculations.",
                context,
              "levan-polkka"
            ),
          if (currentPhase >= 16)
            _buildNumberDescription(
                "Stage 16: ω100(↑)ε0 + 1",
                "Diving deeper into the world of hyper-operations and ordinals",
                "This notation describes an extremely large ordinal that surpasses previous fast-growing sequences. "
                    "It is part of a mathematical hierarchy that extends beyond conventional arithmetic and enters set theory.",
                context,
              "mario"
            ),
          if (currentPhase >= 17)
            _buildNumberDescription(
                "Stage 17: ε1 + 1",
                "What happens when we add another ordinal? Let's find out!",
                "ε1 is the next step after ε0, representing the next fixed point of the function ω ^ x = x. "
                    "It is crucial in advanced ordinal analysis and the study of formal mathematical systems.",
                context,
              "pins_song"
            ),
          if (currentPhase >= 18)
            _buildNumberDescription(
                "Stage 18: ω100(↑)ε1 + 1 ",
                "Precise calculations are becoming more and more complex",
                "This represents an even faster-growing transfinite number, extending beyond previous epsilon-based hierarchies. "
                    "Such numbers are mainly used in proof theory and large ordinal research.",
                context,
              "_1"
            ),
          if (currentPhase >= 19)
            _buildNumberDescription(
                "Stage 19: ωε1 ∗ 100 ",
                "The set ε 1 ε 1  finds new horizons in measurement",
                "The ordinal ω ^ ε1 is a crucial stepping stone toward much larger transfinite numbers. "
                    "It is used in theoretical logic and mathematical foundations to analyze infinite sequences.",
                context,
              "pablo"
            ),
          if (currentPhase >= 20)
            _buildNumberDescription(
                "Stage 20: ε100 (Generalized Epsilon Numbers)",
                "The ultimate limit. This is infinity in the classical sense",
                "ε100 is the 100th epsilon number in the sequence of fixed points of ω ^ x = x. "
                    "These numbers extend far beyond standard mathematics and are mainly explored in set theory.",
                context,
              "asian_meme_sound"
            ),
          if (currentPhase >= 21)
            _buildNumberDescription(
                "Stage 21: εω",
                "Huge sets and their interactions. Dive into higher mathematics",
                "",
                context,
              "dame-da-ne"
            ),
          if (currentPhase >= 22)
            _buildNumberDescription(
                "Stage 22: ζ0 + 1 ",
                "We're moving to new levels; the world of ζ0  is now accessible",
                "ζ0 is an ordinal even larger than epsilon numbers, marking a significant expansion in transfinite arithmetic. "
                    "It is part of an advanced sequence that helps define strong limits in proof theory.",
                context,
              "youll-never-see-it-coming-persona-5"
            ),
          if (currentPhase >= 23)
            _buildNumberDescription(
                "Stage 23: ε0 ^ ζ0 * 100",
                "Exponentiation beyond normal mathematics",
                "This notation pushes ordinal hierarchies beyond previous structures "
                    "like ε0 and ζ0 It is used in complex mathematical frameworks that study infinite processes.",
                context,
              "rickroll"
            ),
          if (currentPhase >= 24)
            _buildNumberDescription(
                "Stage 24: 100ε0 ^ ζ0 + 1 ",
                "Where computations become even more abstract",
                "This number continues the extension of epsilon and zeta numbers, reaching extreme transfinite values. "
                    "Such large ordinals are rarely encountered outside of set theory and proof complexity studies.",
                context,
              "jebaited"
            ),
          if (currentPhase >= 25)
            _buildNumberDescription(
                "Stage 25: 𝜑(100, 1) (Veblen Function at Large Indices)",
                "Time to see the most complex computations",
                "The Veblen function φ systematically constructs incredibly large ordinals. "
                    "It extends the hierarchy far beyond epsilon and zeta numbers, defining even larger transfinite sequences.",
                context,
              "iluminati"
            ),
          if (currentPhase >= 26)
            _buildNumberDescription(
                "Stage 26: 100 𝜑(...) (Iterated Veblen Function)",
                "Hyper-operations in all their glory!",
                "These functions define even more complex large ordinals that go beyond any previously described system. "
                    "Their growth rate surpasses all conventional means of numerical representation.",
                context,
              "backrooms"
            ),
          if (currentPhase >= 27)
            _buildNumberDescription(
                "Stage 27: 𝜑(100,...,0,0) (Extreme Large Ordinals)",
                "Numerical power at its peak",
                "This notation describes ordinals that are so large they require recursive definitions to express."
                    "They exist purely within mathematical logic and have no physical application.",
                context,
              "oiia-oiia"
            ),
          if (currentPhase >= 28)
            _buildNumberDescription(
                "Stage 28: Ξ(1, 100) = ω101 ^ (CK) (Chi Function Notation)",
                "This is where computational cosmology begins",
                "The function Ξ(1,100) is part of a system for constructing even larger countable ordinals. "
                    "These ordinals extend beyond the reach of the Veblen function and are studied in descriptive set theory.",
                context,
              "mv-jack-stauber"
            ),
          if (currentPhase >= 29)
            _buildNumberDescription(
                "Stage 29: Ξ(2, 100) = ε101 ^ (CK) (Higher Chi Function)",
                "We've moved beyond familiar numbers; now we have ε101",
                "This step in the Ξ function generates even stronger transfinite numbers, generalizing epsilon hierarchies. "
                    "It appears in complex mathematical proofs dealing with the foundations of large-scale infinities.",
                context,
              "michael-jackson"
            ),
          if (currentPhase >= 30)
            _buildNumberDescription(
                "Stage 30: Ξ(3, 100) = ζ101 ^ (CK)",
                "Deep levels, we're on the edge of understanding",
                "This number pushes the hierarchy beyond epsilon and zeta, reaching extreme transfinite magnitudes."
                    "Such numbers play a role in higher-order logical analysis and combinatorial mathematics.",
                context,
              "toothless-dancing"
            ),
          if (currentPhase >= 31)
            _buildNumberDescription(
                "Stage 31: Ξ(100,0)=Ψ100Ω^Ω)1 (CK) (Psi Function)",
                "Transitioning to new worlds. The nature of numbers has no boundaries",
                "The function Ψ represents a systematic way of defining incomprehensibly large ordinals."
                    "It is used in proof theory to classify strong ordinal limits and study infinite hierarchies.",
                context,
              "top-5-scariest-jumpscares"
            ),
          if (currentPhase >= 32)
            _buildNumberDescription(
                "Stage 32: Ξ(1,0,100) (Multi-Parameter Ordinals)",
                "The true computation at higher levels begins",
                "These advanced ordinal notations describe structured transfinite numbers with multiple variables."
                    "They extend far beyond conventional set theory into the study of strong determinacy principles.",
                context,
              "lets-go"
            ),
          if (currentPhase >= 33)
            _buildNumberDescription(
                "Stage 33: Ξ(1,0,100Ξ(... (Recursive Ordinal Hierarchies)",
                "We're diving deeper. These computations will take a long time to solve",
                "This notation represents a self-referencing ordinal hierarchy, growing beyond previous frameworks."
                    "It is part of an ongoing mathematical effort to classify large infinities in a structured way.",
                context,
                "dore-dore"
            ),
          if (currentPhase >= 34)
            _buildNumberDescription(
                "Stage 34: Ξ(100Ω Ω ) (Ultimate Transfinite Number in This System)",
                "Completely beyond the limits of all known theories",
                "This is among the largest notations expressible within this framework, pushing ordinal systems to their limit."
                    "It exists purely as a theoretical construct used in advanced research in mathematical logic.",
                context,
              "well-be-right-back"
            ),
          // Добавить другие этапы по аналогии
        ],
      ),
    );
  }

  // Функция для построения виджета с описанием
  Widget _buildNumberDescription(String abbreviation, String description, String notification, BuildContext context, String sfx) {
    final player = MusicPlayer();
    return Visibility(
      // visible: _hasReachedThreshold(threshold),
      child: Column(
        children: [
          ListTile(
            title: Text(abbreviation),
            subtitle: Text(description),
            onTap: () => {
              player.playSoundEffect('34/$sfx.mp3'),
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(notification),
              ),
            ),
            }
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
