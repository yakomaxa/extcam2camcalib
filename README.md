extcam2camcalib

externalcamera.cfgからOculus Mixed Reality Captureのためのxmlをつくるスクリプトです。

Rあるいはpythonで書いてあり、中身は多分一緒です。

利便性のためバイナリにしたくてpythonのも書いたのですが、いまのところできてません。WindowsでPyinstallerつかうの初めてで挫折。

```python ./extcam2camcalib.py input.cfg output.xml```

```Rscript ./extcam2camcalib.R input.cfg output.xml```

-------------------------------------------------
extcam2camcalib

A R/python script to convert externalcamera.cfg from SteamVR into cameracalibration.xml for Oculus Mixed Reality Capture.

Simple usage:

```python ./extcam2camcalib.py input.cfg output.xml```

or

```Rscript ./extcam2camcalib.R input.cfg output.xml```

At this moment, some parameters like display-width, height, and Y-axis intercept may be hardcoded.

I intended to complie python scirpt, but I've got lost.

