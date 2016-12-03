#!/bin/bash -x

init_image_size=1000 #Starting output size
final_image_size=1200 #Final output size
num_image_outputs=2 #Number of outputs between initial and final output

 #Check for output directory, and create it if missing
if [ ! -d "$output" ]; then
  mkdir output
fi

main(){
    # 1. input image
    input=$1
    input_file=`basename $input`
    clean_name="${input_file%.*}"

    # 2. Style image
    style=$2
    style_dir=`dirname $style`
    style_file=`basename $style`
    style_name="${style_file%.*}"
    
    #Defines the output directory
    output="./output"
    out_file=$output/$input_file
    
    #Define current output size value
    current_image_size=$init_image_size


###############################################

neural_style $input $style $out_file

###############################################

init_image_size=$current_image_size

$init_image_size $final_image_size

$num_image_outputs

$math=`echo $final_image_size $init_image_size | awk '{print $1-$2}'`
$math2=`echo $math $num_image_outputs | awk '{print $1/$2}'`

###############################################

for r in `seq 1 $num_frames`;
do 

$current_image_size=`echo $math2 $current_image_size | awk '{print $1+$2}'`


neural_style $input $style $out_file

done

}

retry=0

###############################################

#Specific the Neural-Style command used for each frame here:

neural_style(){
    echo "Neural Style Transfering "$1
    if [ ! -s $3 ]; then
        th neural_style.lua -content_image $1 -style_image $2 -output_image $3 \
            			-image_size $current_image_size -print_iter 100 -backend cudnn -gpu 0 -save_iter 0 \
                		-style_weight 20 -num_iterations 10 
                #-original_colors 1
    fi
    if [ ! -s $3 ] && [ $retry -lt 3 ] ;then
            echo "Transfer Failed, Retrying for $retry time(s)"
            retry=`echo 1 $retry | awk '{print $1+$2}'`
            neural_style $1 $2 $3
    fi
    retry=0
}
main $1 $2 $3 $4 $5 
