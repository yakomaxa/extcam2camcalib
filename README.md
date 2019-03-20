
# extcam2camcalib

externalcamera.cfgからOculus Mixed Reality Captureのカメラ位置設定xmlをつくるスクリプトです。

きわめて適当にR or pythonで書いてあり、中身は多分一緒です。

利便性のためバイナリにしたくてpythonのも書いたのですが、WindowsでPyinstallerつかうの初めてで挫折。やる気がでたらバイナリも置きます。

こんな感じで使います。

```Rscript ./extcam2camcalib.R input.cfg output.xml```

```python ./extcam2camcalib.py input.cfg output.xml```

スクリプトと同じディレクトリにtemplate.xml（一緒に置いてあるやつ）が必要です。

-------------------------------------------------

A R/python script to convert externalcamera.cfg from SteamVR into cameracalibration.xml for Oculus Mixed Reality Capture.

You need template.xml in the same directory as the script.

Simple usage:

```python ./extcam2camcalib.py input.cfg output.xml```

or

```Rscript ./extcam2camcalib.R input.cfg output.xml```

At this moment, some parameters like display-width, height, and Y-axis intercept may be hardcoded.

I intended to complie python scirpt, but I've got lost.
