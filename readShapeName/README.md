# Filter Shapes in PCB

## Instruction
  read_Shape_Name Skill will automatically help you filter out all shapes in your PCB then list them in the form for easily access. This skill is very helpful when you do QA process\
  This skill has already been tested on Allegro 17.2
  
 ## Installation and Using
   **1.** Copy *readShapeNamev2.0.ile* file into: folder:///[YourInstallationDirection]/SPB_17.2/share/local/pcb/skill/ \
   **2.** Copy *readShapeName.form* file into: folder:///[YourInstallationDirection]/SPB_17.2/share/local/pcb/form/ \
   **3.** Open *allegro.ilinit* then copy this command `load "readShapeNamev2.0.ile" "123qweasd"` into your file \
   *Note1: You can locate your allegro.ilinit by searching "HOME"" variable in Environment Variables (Picture below)* \
   *Note2: You can create shortcut key for easily running by adding command into allegro.ilinit that following systax -- `load "readShapeNamev2.0.ile" "123qweasd"	 ; [yourShortcutKey]`*  or by configuring alias in env file -- `alias rsn	read_shape_name`\
   *Example: `load "readShapeNamev2.0.ile" "123qweasd" ;rsn`* \
   **4.** Restart your Allegro Software \
   **5.** To run the skill, type `read_shape_name` or  `rsn` in command box\
   ![image](https://user-images.githubusercontent.com/64115895/159395511-764a7081-957e-4277-89ff-a0c5de4f153b.png)
   
## Screenshot
![Form_2](https://user-images.githubusercontent.com/64115895/159330333-0f60a936-d320-4874-b7af-1b0fdf578a59.JPG)

 ## Documentation
 *  "Skill Language User Guide", Link: http://pwp.gatech.edu/wp-content/uploads/sites/367/2016/03/Intro_to_skill_prog.pdf
 *  "Reference Designer Tutorials", Link: http://www.referencedesigner.com/tutorials/index.php
 *  "allegro-script-add_layer_name", Link: https://github.com/FEDEVEL/allegro-script-add_layer_name
 *  "Form Interface Functions", Link: file:///[YourInstallationDirection]/SPB_17.2/doc/algroskill/11frmint.html
 *  "Allegro Skill Example": Link: folder:///[YourInstallationDirection]/SPB_17.2/doc/algroskill/
 
 ## Contact
 Email: thanhhaipif96@gmail.com

 
