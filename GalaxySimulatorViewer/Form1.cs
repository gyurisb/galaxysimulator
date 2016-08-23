using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace GalaxySimulatorViewer
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private async void button1_Click(object sender, EventArgs e)
        {
            using (BinaryReader reader = new BinaryReader(new FileStream("timeline.dat", FileMode.Open, FileAccess.Read)))
            {
                using (Graphics g = this.panel1.CreateGraphics())
                {
                    BufferedGraphicsContext myContext = BufferedGraphicsManager.Current;
                    Pen pen = new Pen(Color.Red, 2);
                    Brush brush = new SolidBrush(this.panel1.BackColor);
                    double spaceBorder = (1 << 14) * 1.1;
                    long streamLen = reader.BaseStream.Length;

                    int bodyCount = reader.ReadInt32();
                    long cycles = (streamLen - 4) / (12*bodyCount);
                    totalCycleLabel.Text = "/" + cycles;
                    for (long n = 0; n < cycles; n++)
                    {
                        int halfHeight = this.panel1.Height / 2;
                        int halfWidth = this.panel1.Width / 2;
                        var points = new Tuple<int, int, int>[bodyCount];
                        for (int i = 0; i < bodyCount; i++)
                        {
                            int x = reader.ReadInt32();
                            int y = reader.ReadInt32();
                            int weight = reader.ReadInt32();

                            if (weight >= 0)
                            {
                                int pixelX = (int)(x / spaceBorder * halfHeight + halfHeight);
                                int pixelY = (int)(y / spaceBorder * halfHeight + halfHeight);
                                points[i] = Tuple.Create(pixelX, pixelY, weight);
                            }
                        }
                        using (var myBuffer = myContext.Allocate(this.CreateGraphics(), this.panel1.DisplayRectangle))
                        {
                            myBuffer.Graphics.FillRectangle(brush, this.panel1.Bounds);
                            var bodyPoints = points.Where(p => p != null).ToList();
                            foreach (var point in bodyPoints)
                            {
                                myBuffer.Graphics.FillRectangle(ColorOf(point.Item3), point.Item1, point.Item2, 5, 5);
                            }
                            myBuffer.Render(g);
                            labelBodyCount.Text = bodyPoints.Count.ToString();
                        }
                        yearsLabel.Text = n.ToString();
                        int waitTime = (int)Math.Round(100 * (trackBar1.Maximum - trackBar1.Value) / (double)trackBar1.Maximum);
                        await Task.Delay(waitTime);
                    }

                    pen.Dispose();
                    brush.Dispose();
                }
            }
        }

        private static Brush yellorBrush = new SolidBrush(Color.Yellow);
        private static Brush blueBrush = new SolidBrush(Color.Green);
        private static Brush grayBrush = new SolidBrush(Color.Gray);
        private static Brush ColorOf(int weight)
        {
            if (weight > 1900000) return yellorBrush;
            else if (weight > 1000) return blueBrush;
            else return grayBrush;
        }

        private void button2_Click(object sender, EventArgs e)
        {

        }
    }
}
