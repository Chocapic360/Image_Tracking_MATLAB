# Image Tracking Project

This repository contains the implementation of an "Image Tracking" project, focusing on the detection and tracking of moving circular dots within an image sequence. The project aims to identify these dots, which represent moving targets in an Earth Observation (EO) video stream, and mark their centers. This process is crucial for determining the geographic locations of these targets based on associated camera parameters. The project deals with image sequences provided as AVI files and produces an AVI file with the marks placed on the targets. The imagery includes Gaussian noise and Shot noise, simulating real-world errors, and requires cleaning and processing to automatically determine the center of the circular target.

## Project Overview

The project is centered around the concept of image tracking, where an imaging system views a scene containing physical objects. The goal is to design a system that can find, locate, and track these objects within a sequence of images. The objects are treated as rigid bodies, with their locations represented by a single three-dimensional coordinate. For simplicity, the project generalizes the target as a single point with height and breadth, focusing on the center of the objects as their location.

## Image Tracking Concept

The process involves determining which pixels in the image belong to the target/object or the background. This binary image classification allows for the calculation of the center location of an object as the centroid of the target pixels. The centroid is calculated as the average of all row pixels and the average of all column pixels. The size of the object, or the area of the object, is estimated by the total number of target pixels.

## Error of project
![Error Data](https://github.com/Chocapic360/Image_Tracking_MATLAB/Error Data.png)
