namespace GalaxySimulatorViewer
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.panel1 = new System.Windows.Forms.Panel();
            this.button1 = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.yearsLabel = new System.Windows.Forms.Label();
            this.totalCycleLabel = new System.Windows.Forms.Label();
            this.panel2 = new System.Windows.Forms.Panel();
            this.label4 = new System.Windows.Forms.Label();
            this.trackBar1 = new System.Windows.Forms.TrackBar();
            this.labelBodyCount = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.button2 = new System.Windows.Forms.Button();
            this.panel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar1)).BeginInit();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.Black;
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(912, 822);
            this.panel1.TabIndex = 0;
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(27, 12);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 1;
            this.button1.Text = "Start";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(24, 91);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(80, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Ciklusok száma";
            // 
            // yearsLabel
            // 
            this.yearsLabel.AutoSize = true;
            this.yearsLabel.Location = new System.Drawing.Point(32, 112);
            this.yearsLabel.Name = "yearsLabel";
            this.yearsLabel.Size = new System.Drawing.Size(13, 13);
            this.yearsLabel.TabIndex = 3;
            this.yearsLabel.Text = "0";
            // 
            // totalCycleLabel
            // 
            this.totalCycleLabel.AutoSize = true;
            this.totalCycleLabel.Location = new System.Drawing.Point(68, 112);
            this.totalCycleLabel.Name = "totalCycleLabel";
            this.totalCycleLabel.Size = new System.Drawing.Size(18, 13);
            this.totalCycleLabel.TabIndex = 4;
            this.totalCycleLabel.Text = "/0";
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.SystemColors.Control;
            this.panel2.Controls.Add(this.button2);
            this.panel2.Controls.Add(this.label4);
            this.panel2.Controls.Add(this.trackBar1);
            this.panel2.Controls.Add(this.labelBodyCount);
            this.panel2.Controls.Add(this.label2);
            this.panel2.Controls.Add(this.totalCycleLabel);
            this.panel2.Controls.Add(this.label1);
            this.panel2.Controls.Add(this.yearsLabel);
            this.panel2.Controls.Add(this.button1);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Right;
            this.panel2.Location = new System.Drawing.Point(794, 0);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(118, 822);
            this.panel2.TabIndex = 0;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(32, 205);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(54, 13);
            this.label4.TabIndex = 8;
            this.label4.Text = "Sebesség";
            // 
            // trackBar1
            // 
            this.trackBar1.Location = new System.Drawing.Point(23, 221);
            this.trackBar1.Name = "trackBar1";
            this.trackBar1.Size = new System.Drawing.Size(79, 45);
            this.trackBar1.TabIndex = 7;
            // 
            // labelBodyCount
            // 
            this.labelBodyCount.AutoSize = true;
            this.labelBodyCount.Location = new System.Drawing.Point(32, 176);
            this.labelBodyCount.Name = "labelBodyCount";
            this.labelBodyCount.Size = new System.Drawing.Size(13, 13);
            this.labelBodyCount.TabIndex = 6;
            this.labelBodyCount.Text = "0";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(27, 155);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(73, 13);
            this.label2.TabIndex = 5;
            this.label2.Text = "Testek száma";
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(27, 41);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(75, 23);
            this.button2.TabIndex = 9;
            this.button2.Text = "Pause";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(912, 822);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label yearsLabel;
        private System.Windows.Forms.Label totalCycleLabel;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TrackBar trackBar1;
        private System.Windows.Forms.Label labelBodyCount;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button button2;
    }
}

