public class Sentence extends GGen {
    GPlane box;

    GText noun;
    GText verb;
    GText adjective;
    GText adverb;

    vec3 color;

    int hasAdjective;
    int hasNoun;
    int hasVerb;
    int hasAdverb;

    fun @construct() {
        0 => this.hasAdjective;
        0 => this.hasNoun;
        0 => this.hasVerb;
        0 => this.hasAdverb;

        // Color
        Color.random() => this.color;
        @(this.color.x * 2., this.color.y * 2., this.color.z * 2., 1.) => this.noun.color;
        @(this.color.x * 2., this.color.y * 2., this.color.z * 2., 1.) => this.verb.color;
        @(this.color.x * 2., this.color.y * 2., this.color.z * 2., 1.) => this.adjective.color;
        @(this.color.x * 2., this.color.y * 2., this.color.z * 2., 1.) => this.adverb.color;

        Color.BLACK => this.box.color;
        Color.BLACK => this.box.emission;
        Color.BLACK => this.box.specular;

        // Fonts
        "./fonts/FacultyGlyphic-Regular.ttf" => this.noun.font;
        "./fonts/FacultyGlyphic-Regular.ttf" => this.verb.font;
        "./fonts/FacultyGlyphic-Regular.ttf" => this.adjective.font;
        "./fonts/FacultyGlyphic-Regular.ttf" => this.adverb.font;

        // Position
        Math.random2(0, 1) => int nounPlacement;
        Math.random2(0, 1) => int verbPlacement;

        if (nounPlacement == 0) {
            0.3 => this.adjective.posY;
            0.1 => this.noun.posY;

            if (verbPlacement == 0) {
                -0.1 => this.verb.posY;
                -0.3 => this.adverb.posY;
            } else {
                -0.1 => this.adverb.posY;
                -0.3 => this.verb.posY;
            }
        } else {
            0.3 => this.adverb.posY;
            0.1 => this.verb.posY;
            -0.1 => this.adjective.posY;
            -0.3 => this.noun.posY;
        }

        -5. => this.box.posZ;

        // Scale
        @(1., 1., 1.) => this.box.sca;
        @(0.15, 0.15, 1.) => this.noun.sca;
        @(0.15, 0.15, 1.) => this.verb.sca;
        @(0.15, 0.15, 1.) => this.adjective.sca;
        @(0.15, 0.15, 1.) => this.adverb.sca;

        // Name
        "Sentence" => this.name;

        // Connections
        this.box --> this --> GG.scene();
    }

    fun void setPos(float x, float y) {
        @(x, y, 0.) => this.pos;
    }

    fun void glow() {
        @(this.color.x * 10., this.color.y * 10., this.color.z * 10., 1.) => this.noun.color;
        @(this.color.x * 10., this.color.y * 10., this.color.z * 10., 1.) => this.verb.color;
        @(this.color.x * 10., this.color.y * 10., this.color.z * 10., 1.) => this.adjective.color;
        @(this.color.x * 10., this.color.y * 10., this.color.z * 10., 1.) => this.adverb.color;
    }

    fun void setNoun(string text) {
        text => this.noun.text;
        1 => this.hasNoun;
        this.noun --> this;

        if (this.done()) this.glow();
    }

    fun void setVerb(string text) {
        text => this.verb.text;
        1 => this.hasVerb;
        this.verb --> this;

        if (this.done()) this.glow();
    }

    fun void setAdjective(string text) {
        text => this.adjective.text;
        1 => this.hasAdjective;
        this.adjective --> this;

        if (this.done()) this.glow();
    }

    fun void setAdverb(string text) {
        text => this.adverb.text;
        1 => this.hasAdverb;
        this.adverb --> this;

        if (this.done()) this.glow();
    }

    fun int done() {
        return this.hasAdjective && this.hasNoun && this.hasVerb && this.hasAdverb;
    }

    fun void fadeOut() {
        60 * 5 => int numRepeats;
        this.color.x * 10. / numRepeats => float xValDelta;
        this.color.y * 10. / numRepeats => float yValDelta;
        this.color.z * 10. / numRepeats => float zValDelta;

        // Add fadeout here
        repeat (numRepeats) {
            // Noun
            this.noun.color() => vec4 nounColor;
            @(nounColor.x - xValDelta, nounColor.y - yValDelta, nounColor.z - zValDelta, 1.) => this.noun.color;

            // Verb
            this.verb.color() => vec4 verbColor;
            @(verbColor.x - xValDelta, verbColor.y - yValDelta, verbColor.z - zValDelta, 1.) => this.verb.color;

            // Adjective
            this.adjective.color() => vec4 adjectiveColor;
            @(adjectiveColor.x - xValDelta, adjectiveColor.y - yValDelta, adjectiveColor.z - zValDelta, 1.) => this.adjective.color;

            // Adverb
            this.adverb.color() => vec4 adverbColor;
            @(adverbColor.x - xValDelta, adverbColor.y - yValDelta, adverbColor.z - zValDelta, 1.) => this.adverb.color;


            GG.nextFrame() => now;
        }

        // Remove from scene
        this --< GG.scene();
    }

    fun void clear() {
        this --< GG.scene();
    }
}


public class WordManager {
    Sentence sentences[0];

    40 => int MAX_WORDS;
    int numNouns;
    int numVerbs;
    int numAdjectives;
    int numAdverbs;

    fun void clearDone() {
        while (true) {
            int doneIdxs[0];
            for (int idx; idx < this.sentences.size(); idx++) {
                if (this.sentences[idx].done()) {
                    this.numNouns--;
                    this.numVerbs--;
                    this.numAdjectives--;
                    this.numAdverbs--;

                    doneIdxs << idx;
                    spork ~ this.sentences[idx].fadeOut();
                }
            }

            for (int idx : doneIdxs) {
                this.sentences.popOut(idx);
            }

            GG.nextFrame() => now;
        }
    }

    fun void popOut(int idx) {
        60 * 5 => int numRepeats;
        repeat(numRepeats) {
            GG.nextFrame() => now;
        }

        this.sentences.popOut(idx);
    }

    fun void clearOldWords() {
        while (true) {
            int oldIdxs[0];

            if (this.numNouns > this.MAX_WORDS) {
                for (int idx; idx < this.sentences.size(); idx++) {
                    this.sentences[idx] @=> Sentence sentence;
                    if (sentence.hasNoun) {
                        this.numNouns--;
                        if (sentence.hasVerb) this.numVerbs--;
                        if (sentence.hasAdjective) this.numAdjectives--;
                        if (sentence.hasAdverb) this.numAdverbs--;

                        oldIdxs << idx;
                        sentence.clear();
                        break;
                    }
                }
            }

            if (this.numVerbs > this.MAX_WORDS) {
                for (int idx; idx < this.sentences.size(); idx++) {
                    this.sentences[idx] @=> Sentence sentence;
                    if (sentence.hasVerb) {
                        this.numVerbs--;
                        if (sentence.hasNoun) this.numNouns--;
                        if (sentence.hasAdjective) this.numAdjectives--;
                        if (sentence.hasAdverb) this.numAdverbs--;

                        oldIdxs << idx;
                        sentence.clear();
                        break;
                    }
                }
            }

            if (this.numAdjectives > this.MAX_WORDS) {
                for (int idx; idx < this.sentences.size(); idx++) {
                    this.sentences[idx] @=> Sentence sentence;
                    if (sentence.hasAdjective) {
                        this.numAdjectives--;
                        if (sentence.hasNoun) this.numNouns--;
                        if (sentence.hasVerb) this.numVerbs--;
                        if (sentence.hasAdverb) this.numAdverbs--;

                        oldIdxs << idx;
                        sentence.clear();
                        break;
                    }
                }
            }

            if (this.numAdverbs > this.MAX_WORDS) {
                for (int idx; idx < this.sentences.size(); idx++) {
                    this.sentences[idx] @=> Sentence sentence;
                    if (sentence.hasAdverb) {
                        this.numAdverbs--;
                        if (sentence.hasNoun) this.numNouns--;
                        if (sentence.hasVerb) this.numVerbs--;
                        if (sentence.hasAdjective) this.numAdjectives--;

                        oldIdxs << idx;
                        sentence.clear();
                        break;
                    }
                }
            }

            // Clear from list
            for (int idx : oldIdxs) {
                this.sentences.popOut(idx);
            }

            GG.nextFrame() => now;
        }
    }

    fun void setSentencePos(Sentence sentence) {
        float x;
        float y;

        repeat (50) {
            Math.random2f(-5., 5.) => float x;
            Math.random2f(0., 2.) => float y;
            sentence.setPos(x, y);

            1 => int noCollisions;
            for (Sentence other : this.sentences) {
                this.overlap(sentence.box, other.box) => int collision;
                if (collision) {
                    0 => noCollisions;
                    break;
                }
            }

            if (noCollisions) {
                return;
            }
        }

        // Try again, outside of screen bounds
        repeat (50) {
            Math.random2f(-8., 8.) => float x;
            Math.random2f(-4., 4.) => float y;
            sentence.setPos(x, y);

            1 => int noCollisions;
            for (Sentence other : this.sentences) {
                this.overlap(sentence.box, other.box) => int collision;
                if (collision) {
                    0 => noCollisions;
                    break;
                }
            }

            if (noCollisions) {
                return;
            }
        }
    }

    fun int overlap(GPlane curr, GPlane other) {
        curr.scaX() / 2. => float currHalfWidth;
        curr.scaY() / 2. => float currHalfHeight;

        other.scaX() / 2. => float otherHalfWidth;
        other.scaY() / 2. => float otherHalfHeight;

        Math.fabs(curr.parent().posX() - other.parent().posX()) => float xDiff;
        Math.fabs(curr.parent().posY() - other.parent().posY()) => float yDiff;

        currHalfWidth + otherHalfWidth => float widthSum;
        currHalfHeight + otherHalfHeight => float heightSum;

        return (xDiff < widthSum) && (yDiff < heightSum);

    }

    fun void addNoun(string noun) {
        1 => int createNew;

        // Look for existing sentence to add to
        for (Sentence sentence : this.sentences) {
            if (!sentence.hasNoun) {
                sentence.setNoun(noun);
                0 => createNew;
                break;
            }
        }

        // Otherwise create a new one
        if (createNew) {
            Sentence sentence;
            this.setSentencePos(sentence);
            sentence.setNoun(noun);
            this.sentences << sentence;
        }

        this.numNouns++;
    }

    fun void addVerb(string verb) {
        1 => int createNew;

        // Look for existing sentence to add to
        for (Sentence sentence : this.sentences) {
            if (!sentence.hasVerb) {
                sentence.setVerb(verb);
                0 => createNew;
                break;
            }
        }

        // Otherwise create a new one
        if (createNew) {
            Sentence sentence;
            this.setSentencePos(sentence);
            sentence.setVerb(verb);
            this.sentences << sentence;
        }

        this.numVerbs++;
    }

    fun void addAdjective(string adjective) {
        1 => int createNew;

        // Look for existing sentence to add to
        for (Sentence sentence : this.sentences) {
            if (!sentence.hasAdjective) {
                sentence.setAdjective(adjective);
                0 => createNew;
                break;
            }
        }

        // Otherwise create a new one
        if (createNew) {
            Sentence sentence;
            this.setSentencePos(sentence);
            sentence.setAdjective(adjective);
            this.sentences << sentence;
        }

        this.numAdjectives++;
    }

    fun void addAdverb(string adverb) {
        1 => int createNew;

        // Look for existing sentence to add to
        for (Sentence sentence : this.sentences) {
            if (!sentence.hasAdverb) {
                sentence.setAdverb(adverb);
                0 => createNew;
                break;
            }
        }

        // Otherwise create a new one
        if (createNew) {
            Sentence sentence;
            this.setSentencePos(sentence);
            sentence.setAdverb(adverb);
            this.sentences << sentence;
        }

        this.numAdverbs++;
    }
}
