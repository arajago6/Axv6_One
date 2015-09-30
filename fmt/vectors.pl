2950 #!/usr/bin/perl -w
2951 
2952 # Generate vectors.S, the trap/interrupt entry points.
2953 # There has to be one entry point per interrupt number
2954 # since otherwise there's no way for trap() to discover
2955 # the interrupt number.
2956 
2957 print "# generated by vectors.pl - do not edit\n";
2958 print "# handlers\n";
2959 print ".globl alltraps\n";
2960 for(my $i = 0; $i < 256; $i++){
2961     print ".globl vector$i\n";
2962     print "vector$i:\n";
2963     if(!($i == 8 || ($i >= 10 && $i <= 14) || $i == 17)){
2964         print "  pushl \$0\n";
2965     }
2966     print "  pushl \$$i\n";
2967     print "  jmp alltraps\n";
2968 }
2969 
2970 print "\n# vector table\n";
2971 print ".data\n";
2972 print ".globl vectors\n";
2973 print "vectors:\n";
2974 for(my $i = 0; $i < 256; $i++){
2975     print "  .long vector$i\n";
2976 }
2977 
2978 # sample output:
2979 #   # handlers
2980 #   .globl alltraps
2981 #   .globl vector0
2982 #   vector0:
2983 #     pushl $0
2984 #     pushl $0
2985 #     jmp alltraps
2986 #   ...
2987 #
2988 #   # vector table
2989 #   .data
2990 #   .globl vectors
2991 #   vectors:
2992 #     .long vector0
2993 #     .long vector1
2994 #     .long vector2
2995 #   ...
2996 
2997 
2998 
2999 
