# ######################################################################
# Copyright (c) 2014, Gabriel C. Iltis. All rights reserved.           #
#                                                                      #
# Redistribution and use in source and binary forms, with or without   #
# modification, are permitted provided that the following conditions   #
# are met:                                                             #
#                                                                      #
# * Redistributions of source code must retain the above copyright     #
#   notice, this list of conditions and the following disclaimer.      #
#                                                                      #
# * Redistributions in binary form must reproduce the above copyright  #
#   notice this list of conditions and the following disclaimer in     #
#   the documentation and/or other materials provided with the         #
#   distribution.                                                      #
#                                                                      #
# * Neither the name of Gabriel C. Iltis nor the names of additional   #
#   contributors may be used to endorse or promote products derived    #
#   from this software without specific prior written permission.      #
#                                                                      #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  #
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT    #
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS    #
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE       #
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,           #
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES   #
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   #
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)   #
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,  #
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OTHERWISE) ARISING   #
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE   #
# POSSIBILITY OF SUCH DAMAGE.                                          #
########################################################################

proc quant_perSlice {labeled_vol}{
# #########################################
# Area and Volume per Slice for Depth profile comparison
# #########################################
#------------------------------------------------------------------
# Takes a labeled volume (e.g. segmented result) and recasts to proper dType 
# for material statistics calculation. Then modules for calculating both 
# volume and area-per-slice are created. The modules are then executed
# resulting in two Avizo table objects one of which contains the 
# calculated area per slice, and the other containing the calculated 
# volume per slice.
# 
#
# Input
# -----
# labeled_vol : Segmented avizo data set
#   This volume should be the final result of image segmentation
#   I believe this volume needs to be a standard amiraMesh volume object with
#   each material, or phase assigned to a distinct integer value 
#       (e.g.:
#           Exterior = 0
#           Solid Phase = 1
#           Oil Phase = 2
#           Water Phase = 3)
#   However, it may need to be of type LabelField.
#
# Output
# ------
# result_VolumePerSlice : Avizo table object
#   Standard Avizo table containing each slice number and the corresponding 
#   volume measures for all identified phases extending from slice 0 to N.
#
#
# result_AreaPerSlice : Avizo table object
#   Standard Avizo table containing each slice number and the corresponding 
#   volume measures for all identified phases extending from slice 0 to N.
#------------------------------------------------------------------
set hideNewModules 0
create HxCastField {CastField}
CastField data connect $labeled_vol
CastField fire
CastField outputType setIndex 0 6
CastField scaling setValue 1 0
CastField voxelGridOptions setValue 0 1
CastField voxelGridOptions setToggleVisible 0 1
CastField colorFieldOptions setIndex 0 0
CastField fire
CastField setViewerMask 65535

set hideNewModules 0
[ {CastField} create
 ] setLabel {label_field}
label_field master connect CastField
label_field fire
label_field primary setIndex 0 0
label_field fire
label_field setViewerMask 65535

# ------------------------------------------------
# Create material statistics quantification module
set hideNewModules 0
create HxTissueStatistics {MaterialStatistics_Volume}
# ---------------------------------------------------

# Use material statistics quantification module to evaluate volumes
# slice-by-slice (z-axis orientation). So far as I know, if you want
# to evaluate in the other principle directions you'll have to
# reorient you volume using the crop function (swap-axes)

MaterialStatistics_Volume setIconPosition 160 580
MaterialStatistics_Volume data connect label_field
MaterialStatistics_Volume fire
MaterialStatistics_Volume select setIndex 0 2
MaterialStatistics_Volume Options setValue 0 1
MaterialStatistics_Volume Options setToggleVisible 0 1
MaterialStatistics_Volume fire
MaterialStatistics_Volume setViewerMask 65535

set hideNewModules 0
[ {MaterialStatistics_Volume} create
 ] setLabel {result_VolumePerSlice}
result_VolumePerSlice master connect MaterialStatistics_Volume
result_VolumePerSlice fire
result_VolumePerSlice fire
result_VolumePerSlice setViewerMask 65535


# Repeat to quantify surface area
# ---------------------------------------------
# Create material statistics quantification module
# This one focuses on calculating material areas
# Note that the only change in parameters is the
# change to setIndex (from '0 2' to '0 3')
# ---------------------------------------------
set hideNewModules 0
create HxTissueStatistics {MaterialStatistics_Area}
# ---------------------------------------------
MaterialStatistics_Area setIconPosition 160 580
MaterialStatistics_Area data connect label_field
MaterialStatistics_Area fire
MaterialStatistics_Area select setIndex 0 3
MaterialStatistics_Area Options setValue 0 1
MaterialStatistics_Area Options setToggleVisible 0 1
MaterialStatistics_Area fire
MaterialStatistics_Area setViewerMask 65535

set hideNewModules 0
[ {MaterialStatistics_Area} create
 ] setLabel {result_AreaPerSlice}
result_AreaPerSlice master connect MaterialStatistics_Area
result_AreaPerSlice fire
result_AreaPerSlice fire
result_AreaPerSlice setViewerMask 65535
}
