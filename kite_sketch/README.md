# Processing Kite Sketch - Assignment Instructions

## 📁 Folder Structure Required
```
kite_sketch/
├── kite_sketch.pde          (the main code - already done!)
└── data/
    ├── background.jpg       (YOU MUST ADD THIS!)
    └── kite_texture.jpg     (optional - for textured kite)
```

---

## ✅ WHAT YOU NEED TO DO:

### Step 1: Create the "data" folder
1. Open the `kite_sketch` folder
2. Create a new folder inside called `data`

### Step 2: Add Your Background Image
1. Find or create a background image (sky scene works great!)
2. Rename it to `background.jpg`
3. Place it in the `data` folder
4. **Recommended size:** 800x600 pixels

### Step 3: (Optional) Add Kite Texture
1. If you want a textured kite, add an image named `kite_texture.jpg` to the `data` folder
2. If you don't add this, the kite will use solid colors (which also looks fine!)

### Step 4: Change the Letter to YOUR Initial
The current kite is shaped like the letter **"A"**. 

**If your name/surname starts with a different letter, modify the code:**

1. Open `kite_sketch.pde` in Processing
2. Find the function `drawColoredLetterKite()` (around line 170)
3. Modify the `vertex()` coordinates to create YOUR letter shape
4. If you're using texture, also modify `drawTexturedLetterKite()`

**Example letter shapes (vertex coordinates):**

```java
// Letter "M"
vertex(0, -80);     // Top center
vertex(-50, -80);   // Top left
vertex(-50, 60);    // Bottom left
vertex(-25, 60);    // Inner left bottom
vertex(0, 0);       // Middle dip
vertex(25, 60);     // Inner right bottom
vertex(50, 60);     // Bottom right
vertex(50, -80);    // Top right

// Letter "T"
vertex(-50, -80);   // Top left
vertex(50, -80);    // Top right
vertex(50, -50);    // Under top right
vertex(15, -50);    // Right of stem top
vertex(15, 60);     // Right of stem bottom
vertex(-15, 60);    // Left of stem bottom
vertex(-15, -50);   // Left of stem top
vertex(-50, -50);   // Under top left

// Letter "I" (with dashed lines as specified!)
// See special instructions below for letter I
```

### Step 5: Special Case - Letter "I"
If your name starts with "I", you need to add dashed lines at the top and bottom. 
Add this code inside the `drawLetterKite()` function:

```java
// Add dashed line at top
stroke(80, 40, 40);
strokeWeight(2);
for (int i = -40; i < 40; i += 10) {
  line(i, -90, i + 5, -90);
}
// Add dashed line at bottom  
for (int i = -40; i < 40; i += 10) {
  line(i, 70, i + 5, 70);
}
```

### Step 6: Run and Test
1. Open Processing IDE
2. Open the `kite_sketch.pde` file
3. Click the **Run** button (▶️)
4. Watch your kite fly!

### Step 7: Compress for Submission
1. Make sure your sketch runs correctly
2. Close Processing
3. Right-click the entire `kite_sketch` folder
4. Select "Compress" or "Add to archive"
5. Upload the .zip file to ELSE

---

## 📝 UNDERSTANDING THE CODE (for your report):

### Shape Modes Used:
| Mode | What It Does | Used For |
|------|--------------|----------|
| `POINTS` | Individual dots | Stars in sky |
| `LINES` | Pairs of lines | Wind streaks |
| `TRIANGLES` | Groups of 3 vertices | Bunting flags |
| `TRIANGLE_STRIP` | Connected triangles | Ribbon at bottom |
| `TRIANGLE_FAN` | Triangles from center | Sun decoration |
| `QUADS` | Groups of 4 vertices | Checkered ground |
| `QUAD_STRIP` | Connected quads | Path/road |

### Difference Between endShape() and endShape(CLOSE):
- **`endShape()`** - Leaves shape OPEN (last vertex NOT connected to first)
- **`endShape(CLOSE)`** - Closes shape (draws line from last vertex back to first)

### Key Functions Used:
- `PImage` - Stores image data
- `loadImage()` - Loads image from file
- `background()` - Sets background (can use image!)
- `imageMode()` - Sets how images are positioned
- `vertex()` - Defines a point in a shape
- `beginShape()` - Starts defining a shape
- `endShape()` - Finishes a shape
- `texture()` - Applies an image as texture
- `textureMode()` - Sets texture coordinate mode

---

## 🎮 Controls:
- **S key** - Save screenshot
- **R key** - Reset wind angle
- The kite automatically sways with simulated wind!

---

## ❓ Troubleshooting:

**"Image not loading"**
- Make sure the image is in the `data` folder (not just the sketch folder)
- Make sure it's named exactly `background.jpg` (case-sensitive on some systems)

**"Sketch won't run"**
- Make sure you have Processing installed
- Check for syntax errors if you modified the code

**"Kite shape looks wrong"**
- Adjust the vertex coordinates carefully
- Draw your letter on graph paper first to plan coordinates

---

Good luck with your project! 🪁
