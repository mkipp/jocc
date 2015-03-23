# JOCC #

A very simple implementation of the so-called OCC model of emotional processing. It is implemented in the JESS rule language. JESS is a Java-based implementation of the famous CLIPS rule engine. Therefore, it can easily be integrated in Java programs.

This implementation was developed by [Michael Kipp](http://embots.dfki.de/~kipp), [http:embots.dfki.de Embodied Agents Research Group], DFKI Saarbrücken, Germany.

## How to install ##

Download the sources which consist of three files: occ.clp, test.clp and personality.txt (just go to the source tab to know how to do this - you need to install Mercurial before).

Get yourself a copy of JESS from http://www.jessrules.com/

## How to run ##

Open a terminal (shell) and go to the JOCC directory. Now start JESS by typing

```
java -cp jess.jar jess.Main
```

(you need to adjust the path to your jess.jar file)

Now you should see the JESS prompt and you can load the two .clp files by typing

```
(batch "occ.clp")
```

and

```
(batch "test.clp")
```

The first file (occ.clp) contains the actual reasoning, whereas the second file (test.clp) contains some test data. Open the files in an editor to look at them. They are quite readable, even with little knowledge of JESS.