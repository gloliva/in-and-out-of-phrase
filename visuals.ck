public class Knob extends GGen {
    GCylinder border;
    GCylinder knob;
    GPlane indicator;

    fun @construct() {
        // Position
        0.01 => this.knob.posY;
        @(0., 0.51, -0.1) => this.indicator.pos;

        // Scale
        @(0.85, 1., 0.85) => this.knob.sca;
        @(0.04, 0.2, 0.15) => this.indicator.sca;

        // Rotation
        Math.PI / 2 => this.border.rotX;
        Math.PI / 2 => this.indicator.rotX;

        // Color
        Color.DARKGRAY => this.border.color;
        Color.WHITE * 3 => this.knob.color;
        Color.RED => this.indicator.color;

        // Names
        "Border" => this.border.name;
        "Knob Circle" => this.knob.name;
        "Knob Indicator" => this.indicator.name;
        "Knob" => this.name;

        // Connections
        this.indicator --> this.knob --> this.border --> this;
    }

    fun void rotate(int val) {
        Std.scalef(val, 0., 127., -Math.PI / 4, Math.PI / 4) => float rot;
        rot => this.knob.rotZ;
    }
}


public class Slider extends GGen {
    GCube border;
    GCube track;
    GCube slider;

    fun @construct() {
        // Scale
        @(0.8, 4., 0.1) => this.border.sca;
        @(0.2, 3.6, 0.11) => this.track.sca;
        @(0.4, 1.5, 0.3) => this.slider.sca;

        // Color
        Color.LIGHTGRAY => this.border.color;
        Color.BLACK => this.track.color;
        @(0.05, 0.05, 0.05) => this.slider.color;

        // Names
        "Border" => this.border.name;
        "Track" => this.track.name;
        "Slider Cube" => this.slider.name;
        "Slider" => this.name;

        // Connections
        this.border --> this;
        this.track --> this;
        this.slider --> this;
    }

    fun void move(int val) {
        Std.scalef(val, 0., 127., -1., 1.) => float pos;
        pos => this.slider.posY;
    }
}


public class Button extends GGen {
    GCube border;
    GPlane face;
    GText text;

    127 => int PRESS;
    0 => int RELEASE;

    fun @construct() {
        // Position
        0.501 => this.face.posZ;
        0.502 => this.text.posZ;

        // Scale
        @(0.95, 0.95, 0.95) => this.face.sca;
        @(0.6, 0.6, 0.6) => this.text.sca;

        // Color
        Color.WHITE * 3 => this.border.color;
        @(0.05, 0.05, 0.05) => this.face.color;
        @(3., 3., 3., 1.) => this.text.color;

        // Text
        "S" => this.text.text;

        // Names
        "Border" => this.border.name;
        "Face" => this.face.name;
        "Text" => this.text.name;
        "Button" => this.name;

        // Connections
        this.face --> this.border --> this;
        this.text --> this;
    }

    fun void press(int val) {
        if (val == this.PRESS) Color.RED * 3. => this.face.color;
        if (val == this.RELEASE) @(0.05, 0.05, 0.05) => this.face.color;
    }
}


public class Panel extends GGen {
    GPlane panel;
    GText description;

    GText slider1;
    GText slider2;
    GText button1;

    fun @construct() {
        // Position
        @(0., 0.8, 0.01) => this.description.pos;
        @(-0.53, 0.82, 0.01) => this.slider1.pos;
        @(0.50, 0.82, 0.01) => this.slider2.pos;
        @(0., 0., 0.01) => this.button1.pos;

        1.2 => this.description.posY;

        0.251 => this.posZ;

        // Scale
        @(1.9, 2.9, 1.) => this.panel.sca;

        @(0.25, 0.25, 0.25) => this.description.sca;
        @(0.15, 0.15, 0.15) => this.slider1.sca;
        @(0.15, 0.15, 0.15) => this.slider2.sca;
        @(0.12, 0.12, 0.10) => this.button1.sca;

        // Color
        @(0.02, 0.02, 0.02) => this.panel.color;
        // Color.BLACK => this.panel.color;

        @(Color.WHITE.x * 3, Color.WHITE.y * 3, Color.WHITE.z * 3, 1.) => this.description.color;
        @(Color.WHITE.x * 3, Color.WHITE.y * 3, Color.WHITE.z * 3, 1.) => this.slider1.color;
        @(Color.WHITE.x * 3, Color.WHITE.y * 3, Color.WHITE.z * 3, 1.) => this.slider2.color;
        @(Color.WHITE.x * 3, Color.WHITE.y * 3, Color.WHITE.z * 3, 1.) => this.button1.color;

        // Text
        "Speed" => this.slider1.text;
        "Spread" => this.slider2.text;
        "Random" => this.button1.text;

        // Fonts
        "./fonts/FacultyGlyphic-Regular.ttf" => this.description.font;
        "./fonts/FacultyGlyphic-Regular.ttf" => this.slider1.font;
        "./fonts/FacultyGlyphic-Regular.ttf" => this.slider2.font;
        "./fonts/FacultyGlyphic-Regular.ttf" => this.button1.font;

        // Name
        "Panel obj" => this.panel.name;
        "Description Text" => this.description.name;
        "Speed Text" => this.slider1.name;
        "Spread Text" => this.slider2.name;
        "Randomize Text" => this.button1.name;
        "Panel" => this.name;

        // Connections
        this.panel --> this;
        this.description --> this;
        this.slider1 --> this;
        this.slider2 --> this;
        this.button1 --> this;
    }

    fun void setDescriptionText(string text) {
        text => this.description.text;
    }
}


public class MidiDevice extends GGen {
    GCube device;
    Knob knobs[8];
    Slider sliders[8];
    Button soloButtons[4];
    Panel panels[4];

    fun @construct() {
        // Position
        -3.5 => float startPos;
        for (int idx; idx < this.sliders.size(); idx++) {
            startPos + (1. * idx) => this.sliders[idx].posX;
            -0.25 => this.sliders[idx].posY;
            0.501 => this.sliders[idx].posZ;
        }

        [-3.6, -2.55, -1.55, -0.52, 0.52, 1.55, 2.55, 3.6] @=> float knobXPos[];
        for (int idx; idx < this.knobs.size(); idx++) {
            knobXPos[idx] => this.knobs[idx].posX;
            1.1 => this.knobs[idx].posY;
        }

        [-3.09, -1.02, 1.02, 3.09] @=> float soloButtonXPos[];
        for (int idx; idx < this.soloButtons.size(); idx++) {
            soloButtonXPos[idx] => this.soloButtons[idx].posX;
            0.25 => this.soloButtons[idx].posY;
            -0.2 => this.soloButtons[idx].posZ;
        }

        [-3.09, -1.02, 1.02, 3.09] @=> float panelXPos[];
        for (int idx; idx < this.panels.size(); idx++) {
            panelXPos[idx] => this.panels[idx].posX;
        }

        // Scale
        @(8.25, 3., 0.5) => this.device.sca;
        for (int idx; idx < this.sliders.size(); idx++) {
            @(0.5, 0.5, 1.) => this.sliders[idx].sca;
        }

        for (int idx; idx < this.soloButtons.size(); idx++) {
            @(0.25, 0.25, 1.) => this.soloButtons[idx].sca;
        }

        @(0.75, 0.75, 1.) => this.sca;

        // Color
        Color.DARKGRAY => this.device.color;
        // @(0.15, 0., 0.) => this.device.color;

        // Names
        "Border" => this.device.name;
        "Midi Device" => this.name;

        // Connections
        for (Slider slider : this.sliders) {
            slider --> this;
        }

        // for (Knob knob : this.knobs) {
        //     knob --> this;
        // }

        for (Button button : this.soloButtons) {
            button --> this;
        }

        ["Nouns", "Verbs", "Adjectives", "Adverbs"] @=> string descriptions[];
        for (int idx; idx < this.panels.size(); idx++) {
            this.panels[idx] @=> Panel panel;
            descriptions[idx] => panel.setDescriptionText;
            panel --> this;
        }

        this.device --> this --> GG.scene();
    }

    fun void moveSliders(int sliderID, int val) {
        this.sliders[sliderID].move(val);
    }

    fun void rotateKnobs(int knobID, int val) {
        this.knobs[knobID].rotate(val);
    }

    fun void pressSoloButtons(int buttonID, int val) {
        this.soloButtons[buttonID].press(val);
    }
}