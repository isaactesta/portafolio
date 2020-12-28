import cv2
import numpy as np
import pandas as pd
import pickle

import os
import copy

from helper import *

# image size
IMAGE_COMPRESSION_SIZE = 256



def preprocess_images(images_directory):
    # obtain filenames from images directory
    all_files = os.listdir(images_directory)
    all_image_files = [name for name in all_files if name.endswith('.jpg')]
    
    # Fastest way to initialize pandas dataframe to create rows
    # https://stackoverflow.com/questions/10715965/add-one-row-to-pandas-dataframe
    all_rows = []
    for filename in all_image_files:
        full_filename = os.path.join(images_directory, filename)

        image_dict = {}

        image_dict['Type'] = type_from_filename(filename)
        image_dict['Person'] = person_from_filename(filename)
        image_dict['Degree'] = degrees_from_filename(filename)
        image_dict['Orientation'] = orientation_from_filename(filename)
        image_dict['Filename'] = filename[:-4] # remove jpg ending of filename

        image = cv2.imread(full_filename)
        image = cv2.resize(image, (IMAGE_COMPRESSION_SIZE, IMAGE_COMPRESSION_SIZE))
        image_dict['RGB'] = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image_dict['Grayscale'] = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        all_rows.append(image_dict)

    # create dataframe of images
    images = pd.DataFrame(all_rows, columns=('Filename', 'Type', 'Person', 'Degree', 'Orientation', 'Grayscale', 'RGB'))
    images = images.set_index('Filename')

    # return images
    return images

def preprocess_bounding_boxes(metadata_directory):
    # total number of rows
    total_rows = 145
    # obtain all bounding boxes
    bounding_boxes = pd.read_csv(metadata_directory, nrows=total_rows)
    # rename bounding box columns
    bounding_boxes.columns = ['Filename', 'TopLeftX', 'TopLeftY', 'BottomRightX', 'BottomRightY']
    # return bounding boxes
    bounding_boxes = bounding_boxes.set_index('Filename')
    return bounding_boxes


class Box:
    """
    Class to store a bounding box with parameters

    Note:
        This class is used by ImageAccess to store bounding box information in public function
        obtain_data_with_boxes (see below)

    Attributes:
        _left_x: value of leftmost pixel of bounding box
        _top_x: value of topmost pixel of bounding box
        _right_x: value of rightmost pixel of bounding box
        _bot_x: value of bottommost pixel of bounding box
    """

    def __init__(self, top_left_x, top_left_y, bot_right_x, bot_right_y):
        self._left_x = top_left_x
        self._top_y = top_left_y
        self._right_x = bot_right_x
        self._bot_y = bot_right_y
    
    def get_cropped_image(self, image):
        return image[self._top_y : self._bot_y, self._left_x : self._right_x]
    
    def get_width(self):
        return self._right_x - self._left_x
    
    def get_height(self):
        return self._bot_y - self._top_y


class ImageAccess:
    """
    Class to allow access to specific images in images folder

    Note:
        Do not directly create an instance of the class or call init function.
        Only function called should be the public static function obtain_images

    Attributes:
        _images: pandas dataframe containing image and descriptors
    """

     # singleton static instance   
    _instance = None

    def __init__(self):
        if ImageAccess._instance != None:
            raise Exception('Singleton. Please do not directly create instance.')
        else:    
            ImageAccess._instance = self

    def initialize(self):
        if os.path.exists('data.pkl'):
            # if data is already pickled, load it back into df (faster)
            self._images = df = pd.read_pickle('data.pkl')
        else:
            images_dirname = os.path.join(os.path.dirname(os.getcwd()), 'images') # obtain images_directory
            boundingbox_dirname = os.path.join(os.path.dirname(os.getcwd()), 'images/metadata.csv') # obtain metadata directory
            # obtain dfs from both images and metadata
            images = preprocess_images(images_dirname)
            bounding_box = preprocess_bounding_boxes(boundingbox_dirname)
            # merge two data frames
            self._images = images.join(bounding_box)
            # pickle and save images
            self._images.to_pickle('data.pkl')
        
    @staticmethod
    def  _get_instance():
        if ImageAccess._instance == None:
            ImageAccess._instance = ImageAccess()
            ImageAccess._instance.initialize()

        return ImageAccess._instance

    @staticmethod
    def _filter_df(i_type, i_person, i_degrees, i_orientation, i_color):
        instance = ImageAccess._get_instance()
        current_df = instance._images

        if i_type != DataType.ALL_TYPE:
            current_df = current_df.loc[current_df['Type'] == i_type]
        if i_person != Label.ALL_PERSONS:
            current_df = current_df.loc[current_df['Person'] == i_person]
        if i_degrees != Angle.ALL_DEGREES:
            current_df = current_df.loc[current_df['Degree'] == i_degrees]
        if i_orientation != Orientation.ALL_ORIENTATIONS:
            current_df = current_df.loc[current_df['Orientation'] == i_orientation]
        
        return current_df

    @staticmethod
    def obtain_images(i_type=DataType.TRAIN, i_person=Label.ALL_PERSONS, i_degrees=Angle.ALL_DEGREES, i_orientation=Orientation.ALL_ORIENTATIONS, i_color=Color.GRAYSCALE):
        """
        Function to obtain images you want to use for processing or testing 

        Note:
            if obtaining rgb images be careful not to choose too many so you don't run out of memory

        Args:
            i_type: type of image (see helper.py). Default set to ImageAccess.ALL_TYPES
            i_person: person you want (see helper.py). Default set to ImageAccess.ALL_PERSONS
            i_degrees: image angle desired (see helper.py). Default set to ImageAccess.ALL_DEGREES
            i_orientation: desired orientation (see helper.py). Default set to ImageAccess.ALL_PERSONS
            i_color: image color scheme (see helper.py). Default set to ImageAccess.Grayscale

        Returns:
            np array of images filtered from data frame
        """

        current_df = ImageAccess._filter_df(i_type, i_person, i_degrees, i_orientation, i_color)

        if i_color == Color.RGB:
            images = current_df['RGB'].to_numpy()
            return images
        else:
            images = current_df['Grayscale'].to_numpy()
            return images

    @staticmethod
    def obtain_labeled_data(i_type=DataType.TRAIN, i_person=Label.ALL_PERSONS, i_degrees=Angle.ALL_DEGREES, i_orientation=Orientation.ALL_ORIENTATIONS, i_color=Color.GRAYSCALE):
        """
        Function to obtain images with person label (see helper.py) you want to use for processing or testing 

        Note:
            if obtaining rgb images be careful not to choose too many so you don't run out of memory

        Args:
            i_type: type of image (see helper.py). Default set to ImageAccess.ALL_TYPES
            i_person: person you want (see helper.py). Default set to ImageAccess.ALL_PERSONS
            i_degrees: image angle desired (see helper.py). Default set to ImageAccess.ALL_DEGREES
            i_orientation: desired orientation (see helper.py). Default set to ImageAccess.ALL_PERSONS
            i_color: image color scheme (see helper.py). Default set to ImageAccess.Grayscale

        Returns:
            tuple containing: np array of images and np array of labels filtered from data frame
        """

        current_df = ImageAccess._filter_df(i_type, i_person, i_degrees, i_orientation, i_color)

        if i_color == Color.RGB:
            images = current_df['RGB'].to_numpy()
            labels = current_df['Person'].to_numpy()
            return images, labels
        else:
            images = current_df['Grayscale'].to_numpy()
            labels = current_df['Person'].to_numpy()
            return images, labels
        
    @staticmethod
    def obtain_data_with_boxes(i_type=DataType.TRAIN, i_person=Label.ALL_PERSONS, i_degrees=Angle.ALL_DEGREES, i_orientation=Orientation.ALL_ORIENTATIONS, i_color=Color.GRAYSCALE):
        """
        Function to obtain images with person label (see helper.py) and bounding boxes you want to use for processing or testing 

        Note:
            if obtaining rgb images be careful not to choose too many so you don't run out of memory

        Args:
            i_type: type of image (see helper.py). Default set to ImageAccess.ALL_TYPES
            i_person: person you want (see helper.py). Default set to ImageAccess.ALL_PERSONS
            i_degrees: image angle desired (see helper.py). Default set to ImageAccess.ALL_DEGREES
            i_orientation: desired orientation (see helper.py). Default set to ImageAccess.ALL_PERSONS
            i_color: image color scheme (see helper.py). Default set to ImageAccess.Grayscale

        Returns:
            tuple containing: np array of images, np array of labels, and np array of boxes (see above) filtered from data frame
        """

        current_df = ImageAccess._filter_df(i_type, i_person, i_degrees, i_orientation, i_color)

        labels = current_df['Person'].to_numpy()
        top_left_x = current_df['TopLeftX'].to_numpy()
        top_left_y = current_df['TopLeftY'].to_numpy()
        bot_right_x = current_df['BottomRightX'].to_numpy()
        bot_right_y = current_df['BottomRightY'].to_numpy()
        boxes = [Box(top_left_x[i], top_left_y[i], bot_right_x[i], bot_right_y[i]) for i in range(0, len(top_left_x))]
        boxes = np.array(boxes)

        if i_color == Color.RGB:
            images = current_df['RGB'].to_numpy()
            return images, labels, boxes
        else:
            images = current_df['Grayscale'].to_numpy()
            return images, labels, boxes
    