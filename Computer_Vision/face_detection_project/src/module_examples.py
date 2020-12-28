import matplotlib.pyplot as plt
import cv2

from helper import *
from image_access import ImageAccess

import os


"""
Module used to show use cases (examples) for different helper classes
created
"""


### ImageAccess Class use case ###
# Initially import ImageAccess from image_accesss module (see above)
def test_image_access_functionality():
    # only call function obtain_images: ImageAccess.obtain_images(i_type, i_person, i_degrees, i_orientation, i_color)

    # obtain all akshay training images as grayscale
    images_1 = ImageAccess.obtain_images(i_person=Label.AKSHAY)
    print(images_1.shape)
    # obtain all 30 degrees nabilah training images as grayscale
    images_2 = ImageAccess.obtain_images(i_person=Label.NABILAH, i_degrees=Angle.DEG_30)
    print(images_2.shape)
    # obtain all 45 degrees left oriented training images as grayscale
    images_3 = ImageAccess.obtain_images(i_degrees=Angle.DEG_45, i_orientation=Orientation.LEFT)
    print(images_3.shape)
    # obtain all 0 degrees akshay images as rgb
    images_4 = ImageAccess.obtain_images(i_person=Label.AKSHAY, i_degrees=Angle.DEG_0, i_color=Color.RGB)
    print(images_4.shape)

    plt.imshow(images_1[0], cmap='gray')
    plt.show()
    plt.imshow(images_2[0], cmap='gray')
    plt.show()
    plt.imshow(images_3[0], cmap='gray')
    plt.show()
    plt.imshow(images_4[0])
    plt.show()

### helper module use case ###
# initially import all from helper module (see above)
def test_labeled_data_and_validation():
    # obtain all training data with corresponding labels
    X_train, Y_train = ImageAccess.obtain_labeled_data() # everything default gives training images

    # check accuracy of Y_train on Y_train (should give 100 % or 1)
    accuracy = get_accuracy(Y_train, Y_train)
    print(accuracy)

    # check confusion matrix of Y_train on Y_train (should give identity matrix)
    matrix = get_confusion_matrix(Y_train, Y_train)
    print(matrix)

### bounding box testing ###
def test_bounding_box_validity():
    # make a temporary directory to store images
    try:
        os.mkdir('cropped')
    except OSError:
        print ("Creation of the directory failed")

    X, Y, boxes = ImageAccess.obtain_data_with_boxes(i_type=DataType.ALL_TYPE) # everything default gives training images
    for i in range(0, len(boxes)):
        cv2.imwrite('cropped/t'+str(i)+'.png', boxes[i].get_cropped_image(X[i]))


images_1 = ImageAccess.obtain_images(i_type=DataType.TEST, i_color=Color.RGB)

for image in images_1:
    plt.imshow(image)
    plt.show()