# Filter Nets Following Functions: CCIX/PCIe, I2C, SPI, UART, CLK/XTAL/OSC

## Instruction
  proView Skill will automatically help you filter out all nets following functions such as: CCIX/PCIe, I2C, SPI, UART, CLK/XTAL/OSC
 in your PCB then list them in the form for easily access. This skill is very helpful when you do QA process\
  This skill has already been tested on Allegro 17.2
  
 ## Installation and Using
   **1.** Copy *proView.ile* file into: folder:///[YourInstallationDirection]/SPB_17.2/share/local/pcb/skill/ \
   **2.** Copy *proView.form* file into: folder:///[YourInstallationDirection]/SPB_17.2/share/local/pcb/forms/ \
   **3.** Open *allegro.ilinit* then copy this command `load "proView.ile" "123qweasd"` into your file \
   *Note1: You can locate your allegro.ilinit by searching "HOME"" variable in Environment Variables (Picture bewlow)* \
   *Note2: You can create shortcut key for easily running by adding command into allegro.ilinit that following systax -- `load "proView.ile" "123qweasd"	 ; [yourShortcutKey]`*  or by configuring alias in env file -- `alias pv	pro_view`\
   *Example: `load "proView.ile" "123qweasd" ;pv`* \
   **4.** Restart your Allegro Software \
   **5.** To run the skill, type `pro_view` or  `pv` in command box 
   
   ![image](https://user-images.githubusercontent.com/64115895/159395511-764a7081-957e-4277-89ff-a0c5de4f153b.png)
   
## Screenshot
![Form](https://user-images.githubusercontent.com/64115895/159330122-295444fe-d9b8-4d18-9ade-caad34969af8.JPG)

 ## Documentation
 *  "Skill Language User Guide", Link: http://pwp.gatech.edu/wp-content/uploads/sites/367/2016/03/Intro_to_skill_prog.pdf
 *  "Reference Designer Tutorials", Link: http://www.referencedesigner.com/tutorials/index.php
 *  "allegro-script-add_layer_name", Link: https://github.com/FEDEVEL/allegro-script-add_layer_name
 *  "Form Interface Functions", Link: file:///[YourInstallationDirection]/SPB_17.2/doc/algroskill/11frmint.html
 *  "Allegro Skill Example": Link: folder:///[YourInstallationDirection]/SPB_17.2/doc/algroskill/
 
 ## Contact
 Email: thanhhaipif96@gmail.com
