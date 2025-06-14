/*

    How to run:
        `chuck --dac:<device #> --out:<# of channels> main.ck:<midi device #>:<installation mode>`

    For example, running at home for testing:
        `chuck main.ck:0:0`

    Or running in Studio E during the installation:
        `chuck --dac:4 --out:32 main.ck:2:1`

    First arg to main is Midi Device ID
    Second arg to main is 0 for test mode and 1 for installation mode

*/


// Imports
@import "bloom.ck"
@import "visuals.ck"
@import "words.ck"


// Background and Graphics
GWindow.title("Installation");
// GWindow.fullscreen();
GG.scene().camera() @=> GCamera cam;
cam.posZ(8.0);
Color.BLACK => GG.scene().backgroundColor;
GG.scene().light() @=> GLight light;
0.8 => light.intensity;


// Cmdline args
-1 => int midiDevice;
-1 => int installationMode;

if( me.args() >= 2 ) {
    me.arg(0) => Std.atoi => midiDevice;
    me.arg(1) => Std.atoi => installationMode;
} else {
    cherr <= "ERROR: Two arguments must be provided: 1) Midi Device # and 2) Installation Mode" <= IO.nl();
    cherr <= "Number of args provided: " <= me.args() <= IO.nl();
    cherr <= "Please run as `chuck --dac:<device #> --out:<# channels> main.ck:<midi #>:<installation mode>" <= IO.nl();
    me.exit();
}


// Midi
MidiIn min;
MidiMsg msg;

if (!min.open(midiDevice)) {
    <<< "Unable to open midi device with ID", midiDevice >>>;
}

0xB0 => int MIDI_CONTRAL_CHANGE;
0xC0 => int MIDI_PROGRAM_CHANGE;


// Midi Categories
0 => int SLIDERS;
1 => int KNOBS;
2 => int SOLO_BUTTONS;


// Midi CC Numbers
0 => int NOUN_RATE_CHANGE;
1 => int NOUN_SPREAD_CHANGE;
32 => int NOUN_SHUFFLE;

2 => int VERB_RATE_CHANGE;
3 => int VERB_SPREAD_CHANGE;
34 => int VERB_SHUFFLE;

4 => int ADJECTIVE_RATE_CHANGE;
5 => int ADJECTIVE_SPREAD_CHANGE;
36 => int ADJECTIVE_SHUFFLE;

6 => int ADVERB_RATE_CHANGE;
7 => int ADVERB_SPREAD_CHANGE;
38 => int ADVERB_SHUFFLE;


// Audio
-1 => int CHANNEL_START;
-1 => int NUM_CHANNELS;


// Installation is Running
if (installationMode) {
    // CCRMA Studio E
    10 => CHANNEL_START;
    10 => NUM_CHANNELS;
    // 1 => NUM_CHANNELS;
    0.85 => dac.chan(CHANNEL_START).gain;
    0.75 => dac.chan(CHANNEL_START + 1).gain;
// Testing at home
} else {
    // Standard Headphones / Speakers
    0 => CHANNEL_START;
    2 => NUM_CHANNELS;
}


// Installation Variables needed to run the installation for a set time
1::day => dur INSTALLATION_DURATION;


class State {
    int running;
    int done;

    fun @construct() {
        0 => this.done;
        0 => this.running;
    }

    fun void timer(dur duration) {
        1 => this.running;
        duration => now;
        0 => this.running;
        1 => this.done;
    }
}


// Audio layer is a grouping of words, such as "Nouns", "Verbs", etc.
class AudioLayer {
    0 => static int NOUN;
    1 => static int VERB;
    2 => static int ADJECTIVE;
    3 => static int ADVERB;

    FileIO dir;
    string dirPath;
    string files[];

    HPF filts[];
    Gain gains[];
    SndBuf bufs[];

    // Playback mods
    5. => float rate;
    1 => int spread;

    0 => int fileIdx;
    0 => int bufIdx;
    -1 => int spreadIdx;

    // Channel info
    int numChannels;
    int channelStart;

    // Category info
    int category;

    fun @construct(string path, int numChannels, int channelStart, int category) {
        numChannels => this.numChannels;
        channelStart => this.channelStart;
        category => this.category;

        path => this.dirPath;
        path => this.dir.open;
        if (!this.dir.good()) {
            <<< "Unable to open directory at path:", path >>>;
            me.exit();
        }

        // get sample files
        this.dir.dirList() @=> this.files;

        // randomize files
        this.files.shuffle();

        // Audio buffers
        SndBuf bufs[numChannels];
        bufs @=> this.bufs;

        // Filters
        HPF filts[numChannels];
        filts @=> this.filts;

        // Gains
        Gain gains[numChannels];
        gains @=> this.gains;

        // Connect buffers to dac
        for (int idx; idx < numChannels; idx++) {
            0.1 => this.bufs[idx].gain;
            100 => this.filts[idx].freq;
            this.bufs[idx] => this.filts[idx] => dac.chan(channelStart + idx);
        }
    }

    fun void play(dur startDelay, State installationState, WordManager wordManager) {

        startDelay => now;

        while (installationState.running) {
            // Extract word from filename
            this.files[this.fileIdx] => string word;
            word.replace(".wav", "");

            // skip hidden files
            if (word.charAt(0) == ".".charAt(0)) {
                (this.fileIdx + 1) % this.files.size() => this.fileIdx;
                continue;
            }

            // Play current file in current buffer
            this.bufs[this.bufIdx] @=> SndBuf buf;
            this.dirPath + "/" + this.files[this.fileIdx] => buf.read;
            1. => buf.rate;

            // Move to next file
            (this.fileIdx + 1) % this.files.size() => this.fileIdx;

            // Move to next buffer
            (this.bufIdx + this.spread) % this.numChannels => this.bufIdx;

            // Add word to graphics
            if (this.category == this.NOUN) wordManager.addNoun(word);
            else if (this.category == this.VERB) wordManager.addVerb(word);
            else if (this.category == this.ADJECTIVE) wordManager.addAdjective(word);
            else if (this.category == this.ADVERB) wordManager.addAdverb(word);

            // Wait
            this.rate * 1::second => now;
        }
    }

    fun void changeRate(float r) {
        <<< "Change Rate for path", this.dirPath, "to", r >>>;
        r => this.rate;
    }

    fun void changeSpread(int s) {
        <<< "Change Spread for path", this.dirPath, "to", s >>>;
        s => this.spread;
    }

    fun void shuffle() {
        <<< "Shuffle for path", this.dirPath >>>;
        this.files.shuffle();
    }
}


// Instantiate graphics
class GraphicsMsg {
    int category;
    int id;
    int val;

    fun @construct(int category, int id, int val) {
        category => this.category;
        id => this.id;
        val => this.val;
    }
}


class GraphicsQueue {
    GraphicsMsg msgs[0];

    fun void add(GraphicsMsg msg) {
        this.msgs << msg;
    }

    fun void clear() {
        // this.msgs.clear();
        this.msgs.reset();
    }
}


WordManager wordManager;
Bloom bloom(2., 1.);
7 => bloom.levels;


GraphicsQueue queue;
MidiDevice deviceGraphics;
-1.9 => deviceGraphics.posY;
0.35 => deviceGraphics.posZ;


// Handle installation graphics
fun void runGraphics(GraphicsQueue queue) {
    while (true) {
        GG.nextFrame() => now;

        for (GraphicsMsg msg : queue.msgs) {
            if (msg.category == SLIDERS) {
                deviceGraphics.moveSliders(msg.id, msg.val);
            } else if (msg.category == KNOBS) {
                deviceGraphics.rotateKnobs(msg.id, msg.val);
            } else if (msg.category == SOLO_BUTTONS) {
                deviceGraphics.pressSoloButtons(msg.id, msg.val);
            }
        }

        queue.clear();
    }
}


// Start graphics
spork ~ wordManager.clearDone();
spork ~ wordManager.clearOldWords();
spork ~ runGraphics(queue);


// Installation timing
State installationState;
spork ~ installationState.timer(INSTALLATION_DURATION);
me.yield();  // Let timer run first


// Audio layers
AudioLayer nouns("./audio/nouns/", NUM_CHANNELS, CHANNEL_START, AudioLayer.NOUN);
AudioLayer verbs("./audio/verbs/", NUM_CHANNELS, CHANNEL_START, AudioLayer.VERB);
AudioLayer adjectives("./audio/adjectives/", NUM_CHANNELS, CHANNEL_START, AudioLayer.ADJECTIVE);
AudioLayer adverbs("./audio/adverbs/", NUM_CHANNELS, CHANNEL_START, AudioLayer.ADVERB);


// Init change rates
5. => nouns.changeRate;
5. => verbs.changeRate;
5. => adjectives.changeRate;
5. => adverbs.changeRate;


// Init spread size
9 => verbs.changeSpread;
5 => adjectives.changeSpread;


// Turn on each audio layer
spork ~ nouns.play(0::second, installationState, wordManager);
spork ~ verbs.play(500::ms, installationState, wordManager);
spork ~ adjectives.play(2::second, installationState, wordManager);
spork ~ adverbs.play(4::second, installationState, wordManager);


// Handle midi messages for the length of the installation
while( installationState.running ) {
    // wait on the event 'min'
    min => now;

    // Process Midi Event
    while( min.recv(msg) ) {
        msg.data1 => int midiMsg;

        if (midiMsg >= MIDI_CONTRAL_CHANGE && midiMsg < MIDI_PROGRAM_CHANGE) {
            msg.data2 => int controlNum;
            msg.data3 => int data;

            float rateChange;
            int spreadIdx;
            int spreadChange;

            if (data < (127 / 2)) Std.scalef(data, 0, 63, 1, 3.) => rateChange;
            else Std.scalef(data, 63, 127, 3., 15.) => rateChange;
            Std.scalef(data, 0, 127, 1., NUM_CHANNELS) $ int => spreadChange;

            // NOUNS
            if (controlNum == NOUN_RATE_CHANGE) {
                rateChange => nouns.changeRate;
                queue.add(new GraphicsMsg(SLIDERS, 0, data));
            }
            if (controlNum == NOUN_SPREAD_CHANGE) {
                spreadChange => nouns.changeSpread;
                queue.add(new GraphicsMsg(SLIDERS, 1, data));
            }
            if (controlNum == NOUN_SHUFFLE || controlNum == (NOUN_SHUFFLE + 1)) {
                if (data == 127) nouns.shuffle();
                queue.add(new GraphicsMsg(SOLO_BUTTONS, 0, data));
            }


            // VERBS
            if (controlNum == VERB_RATE_CHANGE) {
                rateChange => verbs.changeRate;
                queue.add(new GraphicsMsg(SLIDERS, 2, data));
            }
            if (controlNum == VERB_SPREAD_CHANGE) {
                spreadChange => verbs.changeSpread;
                queue.add(new GraphicsMsg(SLIDERS, 3, data));
            }
            if (controlNum == VERB_SHUFFLE || controlNum == (VERB_SHUFFLE + 1)) {
                if (data == 127) verbs.shuffle();
                queue.add(new GraphicsMsg(SOLO_BUTTONS, 1, data));
            }


            // ADJECTIVES
            if (controlNum == ADJECTIVE_RATE_CHANGE) {
                rateChange => adjectives.changeRate;
                queue.add(new GraphicsMsg(SLIDERS, 4, data));
            }
            if (controlNum == ADJECTIVE_SPREAD_CHANGE) {
                spreadChange => adjectives.changeSpread;
                queue.add(new GraphicsMsg(SLIDERS, 5, data));
            }
            if (controlNum == ADJECTIVE_SHUFFLE || controlNum == (ADJECTIVE_SHUFFLE + 1)) {
                if (data == 127) adjectives.shuffle();
                queue.add(new GraphicsMsg(SOLO_BUTTONS, 2, data));
            }


            // ADVERBS
            if (controlNum == ADVERB_RATE_CHANGE) {
                rateChange => adverbs.changeRate;
                queue.add(new GraphicsMsg(SLIDERS, 6, data));
            }
            if (controlNum == ADVERB_SPREAD_CHANGE) {
                spreadChange => adverbs.changeSpread;
                queue.add(new GraphicsMsg(SLIDERS, 7, data));
            }
            if (controlNum == ADVERB_SHUFFLE || controlNum == (ADVERB_SHUFFLE + 1)) {
                if (data == 127) adverbs.shuffle();
                queue.add(new GraphicsMsg(SOLO_BUTTONS, 3, data));
            }
        }
    }
}
