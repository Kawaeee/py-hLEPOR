#!/usr/bin/perl -w  
########################################################################################################################################################################################
##    For a detailed description of this evaluation metric and source code, please read:                                                                                           #####
##    This code is to implement the Machine Translation Evaluation metric hLEPOR                                                                                                   #####
##    hLEPOR evaluation metric is proposed by Aaron Li-Feng Han, Derek F. Wong, Lidia S. Chao, Liangye He and Yi Lu in University of Macau                                         #####
##    This perl code is written by Aaron Li-Feng Han in university of macau, 2013.04                                                                                              #####
##    All Copyright (c) preserved by the authors. Corresponding author: Aaron Li-Feng Han < hanlifengaaron@gmail.com >                                                             #####
##    Please cite paper below if you use the metric or source code in your research work                                                                                           #####
##    "Unsupervised Quality Estimation Model for English to German Translation and Its Application in Extensive Supervised Evaluation". Aaron Li-Feng Han, Derek F. Wong,          #####
##    Lidia S. Chao, Liangye He and Yi Lu. The Scientific World Journal, Issue: Recent Advances in Information Technology. Hindawi Publishing Corporation.                         #####
##    Source code website: https://github.com/aaronlifenghan/aaron-project-lepor                                                                                                   #####
##    Online paper: http://www.hindawi.com/journals/tswj/                                                                                                                          #####
########################################################################################################################################################################################
##    How to use this Perl code and how to assign the weights of sub-factors, e.g. Precision, Recall, Length penalty, Position difference penalty, et.                             #####
##    1. Your system output translation documents and the reference translation document should contain the plain text only, each line containing one sentence, no empty line.     #####
##    2. Put you system output translation documents under the address in Line 23, 53, 55 of this Perl code.                                                                       #####
##    3. Put you reference translation document under the address in Line 27 of this Perl code.                                                                                    #####
##    4. Tune the alpha:beta(Recall:Precision) weights in Line 176; Tune the HPR:ELP:NPP weights in Line 369-371 of this Perl code.                                                #####
##    5. The document containing evaluation score of hLEPOR will be shown under the address in Line 57 of this Perl code.                                                          #####
##                                                                                                                                                                                 #####
########################################################################################################################################################################################

use Getopt::Long;

GetOptions('ref=s' => \my $ref, 'cand=s' => \my $cand, );

# locate the exact reference file here, i.e. ending with the name of the file, not only the directory.
# put the address of reference translation document here
open REF, "<:encoding(utf8)", $ref or die "can't open reference file\n";

$j = 0;
$str1 = "";
@arry_r1 = ();
@arry_ref_length = ();
@arrytwo_ref_translation = ();
$num_of_ref_sentence = 0;

# put the reference translation into a two dimension array @arrytwo_ref_translation
while ($str1 = <REF> ) {
    chomp($str1);
    $str1 = lc($str1);
    # when doing the matching, lower and uppercase is considered the same
    @arry_r1 = split(/\s+/, $str1);
    $arry_ref_length[$j] = scalar(@arry_r1);
    # @arry_ref_length store the lengths of every sentence(line) of the reference translation.
    $j++;
    push @arrytwo_ref_translation, [@arry_r1];
    @arry_r1 = ();
}

$num_of_ref_sentence = $j;
close REF;

# go through all the files in the route
# the candidate, to be evaluated files are suggested to put in a different folder than the reference file and the code file, since the code will automatically evaluate all the files as candidate translation files;
# put system output files directory here, and $file is a variable to represent the files you located in this folder, i.e., if you have several translation output files, the code can run them out at the same time; no need to put exact file name.
if (!(-d $cand)) {
    # the same directory with last line
    open(TEST, "<:encoding(utf8)", $cand) || die "can not open file: $!";
    # this the directory to store scores, suggest to put score files into a different folder as well for easy check.
    # open(RESULT, ">$out") || die "output not found: $!";
    $i = 0;
    $str0 = "";
    @arry_1 = ();
    @arry_sys_length = ();
    @arrytwo_sys_translation = ();
    $sentence_num = 0;
    # put the system translation into a two dimension array @arrytwo_sys_translation
    while ($str0 = <TEST> ) {
        chomp($str0);
        # both reference and system output translation is turned into lowercase
        $str0 = lc($str0);
        @arry_1 = split(/\s+/, $str0);
        # @arry_sys_length store the lengths of every sentences(line) of the system translation.
        $arry_sys_length[$i] = scalar(@arry_1);
        $i++;
        push @arrytwo_sys_translation, [@arry_1];
        @arry_1 = ();
    }
    $sentence_num = $i;
    close TEST;
    print 'length of sysoutput:', "\n", "@arry_sys_length", "\n", $sentence_num, "\n";

    print 'length of reference:', "\n", "@arry_ref_length", "\n", $num_of_ref_sentence, "\n";

    @LP = ();
    # @LP store the longth penalty coefficient of every LP[i]
    for ($k = 0; $k < $sentence_num; $k++) {
        if ($arry_sys_length[$k] > 0 && $arry_ref_length[$k] > 0) {
            if ($arry_sys_length[$k] > $arry_ref_length[$k]) {
                if ($arry_ref_length[$k] > 0) {
                    $LP[$k] = exp(1 - ($arry_sys_length[$k] / $arry_ref_length[$k]));
                } else {
                    $LP[$k] = 0;
                }

            } else {
                if ($arry_sys_length[$k] == 0) {
                    $LP[$k] = 0;
                }
                elsif($arry_sys_length[$k] > 0) {
                    $LP[$k] = exp(1 - ($arry_ref_length[$k] / $arry_sys_length[$k]));
                }
                # $LP[$k] = exp(1 - ($arry_ref_length[$k] / $arry_sys_length[$k]));
            }
        }
    }
    print 'length penalty with longer or shorter:', "\n", "@LP", "\n", $k, "\n";
    $Mean_LP = 0;
    for ($k = 0; $k < $sentence_num; $k++) {
        $Mean_LP = $Mean_LP + $LP[$k];
    }
    $Mean_LP = $Mean_LP / $sentence_num;
    # $Mean_LP = $Mean_LP / 2051;
    print 'mean of length penalty with longer or shorter:', "\n", "$Mean_LP", "\n", $k, "\n";

    @common_num = ();
    # store the common number between sys and ref into @common_num
    for ($i = 0; $i < $sentence_num; $i++) {
        # everytime, select one sentence from the sys, clear the record array
        $m = 0;
        @record_position = ();
        for ($j = 0; $j < $arry_sys_length[$i]; $j++) {
            for ($k = 0; $k < $arry_ref_length[$i]; $k++) {
                if ($arrytwo_sys_translation[$i][$j] eq $arrytwo_ref_translation[$i][$k]) {
                    # every word in the reference use not more than once to matched
                    # if(!(any(@record_position) eq $k))
                    if (!(grep(/^$k/, @record_position))) {
                        $common_num[$i]++;
                        # record the position in the reference already matched
                        $record_position[$m] = $k;
                        $m++;
                        # every word of the sys only match the reference once
                        last;
                    }

                }
            }
        }
    }
    print 'common number between sys and ref:', "\n", "@common_num", "\n", $i, "\n";

    @P = ();
    @R = ();
    # calculate the precision and recall into @P and @R
    for ($i = 0; $i < $sentence_num; $i++) {
        if (($common_num[$i]) != 0) {
            $P[$i] = $common_num[$i] / $arry_sys_length[$i];
            $R[$i] = $common_num[$i] / $arry_ref_length[$i];
        } else {
            $P[$i] = 0;
            $R[$i] = 0;
        }
    }
    print 'precision of sys:', "\n", "@P", "\n", $i, "\n";
    print 'recall of sys:', "\n", "@R", "\n", $i, "\n";

    $Mean_precision = 0;
    $Mean_recall = 0;
    for ($i = 0; $i < $sentence_num; $i++) {
        $Mean_precision = $Mean_precision + $P[$i];
        $Mean_recall = $Mean_recall + $R[$i];
    }
    $Mean_precision = $Mean_precision / $sentence_num;
    $Mean_recall = $Mean_recall / $sentence_num;
    print 'mean precision of sys:', "\n", "$Mean_precision", "\n", $i, "\n";
    print 'mean recall of sys:', "\n", "$Mean_recall", "\n", $i, "\n";

    # $a is a variable to be changed according to different language envirenment # # # # H(P, 9 R)
    $a = 9;
    # $a is a variable to be changed according to different language envirenment # # # # H(9 P, R)
    # $a = 1 / 9;
    # $a is a variable to be changed according to different language envirenment # # # # H(P, R)
    # $a = 1;
    # $a is a variable to be changed according to different language envirenment # # # # H(4 P, 6 R)
    # $a = 6 / 4;

    @Harmonic_mean_PR = ();
    # calculate the harmonic mean of P and a * R
    for ($i = 0; $i < $sentence_num; $i++) {
        if ($P[$i] != 0 || $R[$i] != 0) {
            $Harmonic_mean_PR[$i] = ((1 + $a) * $P[$i] * $R[$i]) / ($R[$i] + $a * $P[$i]);
        } else {
            $Harmonic_mean_PR[$i] = 0;
        }
    }
    print 'harmonic of precision and recall:', "\n", "@Harmonic_mean_PR", "\n", $i, "\n";

    $Mean_HarmonicMean = 0;
    for ($i = 0; $i < $sentence_num; $i++) {
        $Mean_HarmonicMean = $Mean_HarmonicMean + $Harmonic_mean_PR[$i];
    }
    $Mean_HarmonicMean = $Mean_HarmonicMean / $sentence_num;
    print 'mean of every sentences harmonic-mean of precision and recall:', "\n", "$Mean_HarmonicMean", "\n", $i, "\n";

    @pos_dif = ();
    @pos_dif_record = ();
    @pos_dif_record_flag = ();
    @pos_dif_record_ref_flag = ();
    # store the position-different value between sys and ref into @pos_dif
    for ($i = 0; $i < $sentence_num; $i++) {
        for ($j = 0; $j < $arry_sys_length[$i]; $j++) {
            # firstly make every system translation word's flag equal to none
            $pos_dif_record_flag[$i][$j] = "none_match";
            #$store_ref_pos = -1000;
            for ($k = 0; $k < $arry_ref_length[$i]; $k++) {
                $pos_dif_record_ref_flag[$i][$k] = "un_confirmed";
                if ($arrytwo_sys_translation[$i][$j] eq $arrytwo_ref_translation[$i][$k]) {
                    # if there is match, then change the flag as exist_match
                    $pos_dif_record_flag[$i][$j] = "exist_match";
                    $flag_confirm = 0;
                    # this word is in the beginning of sys-output sentence, then check its next word match-condition
                    if ($j eq 0) {
                        $condition = 0;
                        # check the following two words' match
                        for ($count_num_sys = 1; $count_num_sys <= 2; $count_num_sys++) {
                            # to match the reference following two words
                            for ($count_num_ref = 1; $count_num_ref <= 2; $count_num_ref++) {
                                if ($arrytwo_sys_translation[$i][$j + $count_num_sys] eq $arrytwo_ref_translation[$i][$k + $count_num_ref]) {
                                    # if the context is also matched then confirm this match
                                    $pos_dif_record_flag[$i][$j] = "confirm_match";
                                    $pos_dif_record_ref_flag[$i][$k] = "is_confirmed";
                                    # record the matched position
                                    $pos_dif_record[$i][$j] = $k;
                                    $flag_confirm = 1;
                                    $condition = 1;
                                    last;
                                }

                            }
                            # check whether it is matched in last loop
                            if ($condition == 1) {
                                last;
                            }
                        }
                    }
                    # this word is '.' or a word in the end of the sys-output sentence
                    elsif(($j eq($arry_sys_length[$i] - 1)) || ($j eq($arry_sys_length[$i] - 2))) {
                        $condition = 0;
                        # check the before two words' match
                        for ($count_num_sys = 1; $count_num_sys <= 2; $count_num_sys++) {
                            # to match the reference before two words
                            for ($count_num_ref = 1; $count_num_ref <= 2; $count_num_ref++) {
                                if ($arrytwo_sys_translation[$i][$j - $count_num_sys] eq $arrytwo_ref_translation[$i][$k - $count_num_ref]) {
                                    # if the context is also matched then confirm this match
                                    $pos_dif_record_flag[$i][$j] = "confirm_match";
                                    $pos_dif_record_ref_flag[$i][$k] = "is_confirmed";
                                    # record the matched position
                                    $pos_dif_record[$i][$j] = $k;
                                    $flag_confirm = 1;
                                    $condition = 1;
                                    last;
                                }

                            }
                            # check whether it is matched in last loop
                            if ($condition == 1) {
                                last;
                            }
                        }
                    }
                    else {
                        # this word is in the middle of sys-output sentence, not beginning and not end
                        $condition = 0;
                        # check the former and back two words' match
                        for ($count_num_sys = -2; $count_num_sys < 2; $count_num_sys++) {
                            # to match the former and back two words' match
                            for ($count_num_ref = -2; $count_num_ref <= 2; $count_num_ref++) {
                                if ($arrytwo_sys_translation[$i][$j + $count_num_sys] eq $arrytwo_ref_translation[$i][$k + $count_num_ref]) {
                                    # if the context is also matched then confirm this match
                                    $pos_dif_record_flag[$i][$j] = "confirm_match";
                                    $pos_dif_record_ref_flag[$i][$k] = "is_confirmed";
                                    # record the matched position
                                    $pos_dif_record[$i][$j] = $k;
                                    $flag_confirm = 1;
                                    $condition = 1;
                                    last;
                                }

                            }
                            # check whether it is matched in last loop
                            if ($condition == 1) {
                                last;
                            }
                        }
                    }
                    # if confirm_match has been down, then the following words in ref neednot go through to match again
                    if ($flag_confirm == 1) {
                        last;
                    }
                }
            }
        }
        # after all the confirm_match has done, then deal with the exist but not confirmed match, using nearest-match
        for ($j = 0; $j < $arry_sys_length[$i]; $j++) {
            $store_ref_unconfirm_pos = -10000;
            for ($k = 0; $k < $arry_ref_length[$i]; $k++) {
                # deal with the existed but not confirmed word in sys-output
                if ($pos_dif_record_flag[$i][$j] eq "exist_match") {
                    if ($arrytwo_sys_translation[$i][$j] eq $arrytwo_ref_translation[$i][$k]) {
                        # every word in the reference use not more than once to matched
                        # if (!(grep(/^$k/, @record_position)))
                        # check whether position k has been confirmed
                        # if (!(grep(/^$k/, @)))
                        # this ref-word has not been confirmed
                        if ($pos_dif_record_ref_flag[$i][$k] eq "un_confirmed") {
                            # select the nearest word from ref to match sys-word
                            if (abs($k - $j) < abs($store_ref_unconfirm_pos - $j)) {
                                $store_ref_unconfirm_pos = $k;
                            }
                        }
                    }
                }
            }
            if ($store_ref_unconfirm_pos >= 0) {
                # record the nearest matched position
                $pos_dif_record[$i][$j] = $store_ref_unconfirm_pos;
            }
        }
        # after all the matched postion recored, then calculate each word's Pos-Diff value
        for ($j = 0; $j < $arry_sys_length[$i]; $j++) {
            if ($pos_dif_record_flag[$i][$j] eq "none_match") {
                # $pos_dif[$i][$j] = abs(($store_ref_pos + 1) / $arry_ref_length[$i] - ($j + 1) / $arry_sys_length[$i]);
                $pos_dif[$i][$j] = 0;
            } else {
                # calculate the matched word's PosDiff
                $pos_dif[$i][$j] = abs((($j + 1) / $arry_sys_length[$i]) - (($pos_dif_record[$i][$j] + 1) / $arry_ref_length[$i]));
            }
        }
    }
    @Pos_dif_sum = ();
    @Pos_dif_value = ();
    for ($i = 0; $i < $sentence_num; $i++) {
        # sum the Pos_dif_distance of one sentence, then divided by the lenth of the sentence
        for ($j = 0; $j < $arry_sys_length[$i]; $j++) {
            # this is original code by simply adding the pos_dif[][], without judging whether the sysout and ref are exact the same sentence.
            # $Pos_dif_sum[$i] = $Pos_dif_sum[$i] + $pos_dif[$i][$j];
            # if the output match othe reference exactly, then NPD = 0 so that PosPenalty = 1, i.e.no penalty.added in 20171013 th
            if (($common_num[$i] == $arry_sys_length[$i]) and($arry_sys_length[$i] == $arry_ref_length[$i])) {
                $Pos_dif_sum[$i] = 0;
            } else {
                $Pos_dif_sum[$i] = $Pos_dif_sum[$i] + $pos_dif[$i][$j];
            }

        }
        if ($arry_sys_length[$i] > 0) {
            $Pos_dif_sum[$i] = $Pos_dif_sum[$i] / $arry_sys_length[$i];
            # calculate the every sentence's value of Pos_dif_value by taking the exp.
            $Pos_dif_value[$i] = exp(-$Pos_dif_sum[$i]);
        }
        # $Pos_dif_sum[$i] = $Pos_dif_sum[$i] / $arry_sys_length[$i];
        # calculate the every sentence's value of Pos_dif_value by taking the exp.
        # $Pos_dif_value[$i] = exp(-$Pos_dif_sum[$i]);
    }
    print 'Position different penalty:', "\n", "@Pos_dif_value", "\n", $i, "\n";
    $Mean_pos_dif_value = 0;
    for ($i = 0; $i < $sentence_num; $i++) {
        $Mean_pos_dif_value = $Mean_pos_dif_value + $Pos_dif_value[$i];
    }
    $Mean_pos_dif_value = $Mean_pos_dif_value / $sentence_num;
    print 'mean Position different penalty:', "\n", "$Mean_pos_dif_value", "\n", $i, "\n";

    # HLEPOR means a new version of MT evaluation metric LEPOR calculated by the harmonic mean of its parameters(not just multiply them)
    @HLEPOR_single_sentence = ();
    $HLEPOR = 0;
    # weight of HPR (harmonic mean of precision and recall)
    $weight_PR = 7;
    # weight of ELP (enhanced length penalty)
    $weight_LP = 2;
    # weight of NPP (n-gram position difference penalty)
    $weight_Pos = 1;

    # calculate the final evaluation value of HLEPOR
    for ($i = 0; $i < $sentence_num; $i++) {
        if ($LP[$i] > 0 && $Pos_dif_value[$i] > 0 && $Harmonic_mean_PR[$i] > 0) {
            $HLEPOR_single_sentence[$i] = ($weight_LP + $weight_Pos + $weight_PR) / ($weight_LP / $LP[$i] + $weight_Pos / $Pos_dif_value[$i] + $weight_PR / $Harmonic_mean_PR[$i]);
        } else {
            $HLEPOR_single_sentence[$i] = 0;
        }

        $HLEPOR = $HLEPOR + $HLEPOR_single_sentence[$i];
    }
    $HLEPOR = $HLEPOR / $sentence_num;
    print 'evaluation value HLEPOR of every single sentence:', "\n", "@HLEPOR_single_sentence", "\n", $i, "\n";
    print 'mean value HLEPOR of all single sentence:', "\n", "$HLEPOR", "\n";

    # another way to calculate the mean HLEPOR of system_output (using all sentences' mean parameter-value)
    $HLEPOR_anotherway = 0;
    if ($Mean_LP > 0 && $Mean_pos_dif_value > 0 && $Mean_HarmonicMean > 0) {
        $HLEPOR_anotherway = ($weight_LP + $weight_Pos + $weight_PR) / ($weight_LP / $Mean_LP + $weight_Pos / $Mean_pos_dif_value + $weight_PR / $Mean_HarmonicMean);
    } else {
            $HLEPOR_anotherway = 0;
    }

    print 'mean value HLEPOR_anotherway of all single sentence:', "\n", "$HLEPOR_anotherway", "\n";

    # close TEST; 
    # close REF;
    # close RESULT;

}