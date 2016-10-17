package require -exact qsys 14.0

# module properties
set_module_property NAME {acDriverQsys_export}
set_module_property DISPLAY_NAME {acDriverQsys_export_display}

# default module properties
set_module_property VERSION {1.0}
set_module_property GROUP {default group}
set_module_property DESCRIPTION {default description}
set_module_property AUTHOR {author}

set_module_property COMPOSITION_CALLBACK compose
set_module_property opaque_address_map false

proc compose { } {
    # Instances and instance parameters
    # (disabled instances are intentionally culled)
    add_instance acDriver acDriver 1.0
    set_instance_parameter_value acDriver {DATA_WDT} {24}
    set_instance_parameter_value acDriver {BCLK_DIVIDER} {2}
    set_instance_parameter_value acDriver {LRCK_DIVIDER} {128}
    set_instance_parameter_value acDriver {CLK_I2C_FRQ} {50000000}
    set_instance_parameter_value acDriver {SCLK_I2C_FRQ} {500000}

    add_instance audioPll altera_pll 15.1
    set_instance_parameter_value audioPll {debug_print_output} {0}
    set_instance_parameter_value audioPll {debug_use_rbc_taf_method} {0}
    set_instance_parameter_value audioPll {gui_device_speed_grade} {8}
    set_instance_parameter_value audioPll {gui_pll_mode} {Integer-N PLL}
    set_instance_parameter_value audioPll {gui_reference_clock_frequency} {50.0}
    set_instance_parameter_value audioPll {gui_channel_spacing} {0.0}
    set_instance_parameter_value audioPll {gui_operation_mode} {direct}
    set_instance_parameter_value audioPll {gui_feedback_clock} {Global Clock}
    set_instance_parameter_value audioPll {gui_fractional_cout} {32}
    set_instance_parameter_value audioPll {gui_dsm_out_sel} {1st_order}
    set_instance_parameter_value audioPll {gui_use_locked} {0}
    set_instance_parameter_value audioPll {gui_en_adv_params} {0}
    set_instance_parameter_value audioPll {gui_number_of_clocks} {1}
    set_instance_parameter_value audioPll {gui_multiply_factor} {1}
    set_instance_parameter_value audioPll {gui_frac_multiply_factor} {1.0}
    set_instance_parameter_value audioPll {gui_divide_factor_n} {1}
    set_instance_parameter_value audioPll {gui_cascade_counter0} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency0} {12.287581}
    set_instance_parameter_value audioPll {gui_divide_factor_c0} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency0} {12.287581 MHz}
    set_instance_parameter_value audioPll {gui_ps_units0} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift0} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg0} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift0} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle0} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter1} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency1} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c1} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency1} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units1} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift1} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg1} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift1} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle1} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter2} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency2} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c2} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency2} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units2} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift2} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg2} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift2} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle2} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter3} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency3} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c3} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency3} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units3} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift3} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg3} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift3} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle3} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter4} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency4} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c4} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency4} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units4} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift4} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg4} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift4} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle4} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter5} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency5} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c5} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency5} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units5} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift5} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg5} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift5} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle5} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter6} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency6} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c6} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency6} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units6} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift6} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg6} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift6} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle6} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter7} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency7} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c7} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency7} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units7} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift7} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg7} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift7} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle7} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter8} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency8} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c8} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency8} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units8} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift8} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg8} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift8} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle8} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter9} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency9} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c9} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency9} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units9} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift9} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg9} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift9} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle9} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter10} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency10} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c10} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency10} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units10} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift10} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg10} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift10} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle10} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter11} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency11} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c11} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency11} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units11} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift11} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg11} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift11} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle11} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter12} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency12} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c12} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency12} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units12} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift12} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg12} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift12} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle12} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter13} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency13} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c13} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency13} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units13} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift13} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg13} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift13} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle13} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter14} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency14} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c14} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency14} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units14} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift14} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg14} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift14} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle14} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter15} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency15} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c15} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency15} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units15} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift15} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg15} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift15} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle15} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter16} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency16} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c16} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency16} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units16} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift16} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg16} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift16} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle16} {50}
    set_instance_parameter_value audioPll {gui_cascade_counter17} {0}
    set_instance_parameter_value audioPll {gui_output_clock_frequency17} {100.0}
    set_instance_parameter_value audioPll {gui_divide_factor_c17} {1}
    set_instance_parameter_value audioPll {gui_actual_output_clock_frequency17} {0 MHz}
    set_instance_parameter_value audioPll {gui_ps_units17} {ps}
    set_instance_parameter_value audioPll {gui_phase_shift17} {0}
    set_instance_parameter_value audioPll {gui_phase_shift_deg17} {0.0}
    set_instance_parameter_value audioPll {gui_actual_phase_shift17} {0}
    set_instance_parameter_value audioPll {gui_duty_cycle17} {50}
    set_instance_parameter_value audioPll {gui_pll_auto_reset} {Off}
    set_instance_parameter_value audioPll {gui_pll_bandwidth_preset} {Auto}
    set_instance_parameter_value audioPll {gui_en_reconf} {0}
    set_instance_parameter_value audioPll {gui_en_dps_ports} {0}
    set_instance_parameter_value audioPll {gui_en_phout_ports} {0}
    set_instance_parameter_value audioPll {gui_phout_division} {1}
    set_instance_parameter_value audioPll {gui_mif_generate} {0}
    set_instance_parameter_value audioPll {gui_enable_mif_dps} {0}
    set_instance_parameter_value audioPll {gui_dps_cntr} {C0}
    set_instance_parameter_value audioPll {gui_dps_num} {1}
    set_instance_parameter_value audioPll {gui_dps_dir} {Positive}
    set_instance_parameter_value audioPll {gui_refclk_switch} {0}
    set_instance_parameter_value audioPll {gui_refclk1_frequency} {100.0}
    set_instance_parameter_value audioPll {gui_switchover_mode} {Automatic Switchover}
    set_instance_parameter_value audioPll {gui_switchover_delay} {0}
    set_instance_parameter_value audioPll {gui_active_clk} {0}
    set_instance_parameter_value audioPll {gui_clk_bad} {0}
    set_instance_parameter_value audioPll {gui_enable_cascade_out} {0}
    set_instance_parameter_value audioPll {gui_cascade_outclk_index} {0}
    set_instance_parameter_value audioPll {gui_enable_cascade_in} {0}
    set_instance_parameter_value audioPll {gui_pll_cascading_mode} {Create an adjpllin signal to connect with an upstream PLL}

    add_instance clk clock_source 15.1
    set_instance_parameter_value clk {clockFrequency} {50000000.0}
    set_instance_parameter_value clk {clockFrequencyKnown} {1}
    set_instance_parameter_value clk {resetSynchronousEdges} {NONE}

    add_instance cpu altera_nios2_gen2 15.1
    set_instance_parameter_value cpu {tmr_enabled} {0}
    set_instance_parameter_value cpu {setting_disable_tmr_inj} {0}
    set_instance_parameter_value cpu {setting_showUnpublishedSettings} {0}
    set_instance_parameter_value cpu {setting_showInternalSettings} {0}
    set_instance_parameter_value cpu {setting_preciseIllegalMemAccessException} {0}
    set_instance_parameter_value cpu {setting_exportPCB} {0}
    set_instance_parameter_value cpu {setting_exportdebuginfo} {0}
    set_instance_parameter_value cpu {setting_clearXBitsLDNonBypass} {1}
    set_instance_parameter_value cpu {setting_bigEndian} {0}
    set_instance_parameter_value cpu {setting_export_large_RAMs} {0}
    set_instance_parameter_value cpu {setting_asic_enabled} {0}
    set_instance_parameter_value cpu {setting_asic_synopsys_translate_on_off} {0}
    set_instance_parameter_value cpu {setting_asic_third_party_synthesis} {0}
    set_instance_parameter_value cpu {setting_asic_add_scan_mode_input} {0}
    set_instance_parameter_value cpu {setting_oci_version} {1}
    set_instance_parameter_value cpu {setting_fast_register_read} {0}
    set_instance_parameter_value cpu {setting_exportHostDebugPort} {0}
    set_instance_parameter_value cpu {setting_oci_export_jtag_signals} {0}
    set_instance_parameter_value cpu {setting_avalonDebugPortPresent} {0}
    set_instance_parameter_value cpu {setting_alwaysEncrypt} {1}
    set_instance_parameter_value cpu {io_regionbase} {0}
    set_instance_parameter_value cpu {io_regionsize} {0}
    set_instance_parameter_value cpu {setting_support31bitdcachebypass} {1}
    set_instance_parameter_value cpu {setting_activateTrace} {0}
    set_instance_parameter_value cpu {setting_allow_break_inst} {0}
    set_instance_parameter_value cpu {setting_activateTestEndChecker} {0}
    set_instance_parameter_value cpu {setting_ecc_sim_test_ports} {0}
    set_instance_parameter_value cpu {setting_disableocitrace} {0}
    set_instance_parameter_value cpu {setting_activateMonitors} {1}
    set_instance_parameter_value cpu {setting_HDLSimCachesCleared} {1}
    set_instance_parameter_value cpu {setting_HBreakTest} {0}
    set_instance_parameter_value cpu {setting_breakslaveoveride} {0}
    set_instance_parameter_value cpu {mpu_useLimit} {0}
    set_instance_parameter_value cpu {mpu_enabled} {0}
    set_instance_parameter_value cpu {mmu_enabled} {0}
    set_instance_parameter_value cpu {mmu_autoAssignTlbPtrSz} {1}
    set_instance_parameter_value cpu {cpuReset} {0}
    set_instance_parameter_value cpu {resetrequest_enabled} {1}
    set_instance_parameter_value cpu {setting_removeRAMinit} {0}
    set_instance_parameter_value cpu {setting_shadowRegisterSets} {0}
    set_instance_parameter_value cpu {mpu_numOfInstRegion} {8}
    set_instance_parameter_value cpu {mpu_numOfDataRegion} {8}
    set_instance_parameter_value cpu {mmu_TLBMissExcOffset} {0}
    set_instance_parameter_value cpu {resetOffset} {0}
    set_instance_parameter_value cpu {exceptionOffset} {32}
    set_instance_parameter_value cpu {cpuID} {0}
    set_instance_parameter_value cpu {breakOffset} {32}
    set_instance_parameter_value cpu {userDefinedSettings} {}
    set_instance_parameter_value cpu {tracefilename} {}
    set_instance_parameter_value cpu {resetSlave} {mem.s1}
    set_instance_parameter_value cpu {mmu_TLBMissExcSlave} {None}
    set_instance_parameter_value cpu {exceptionSlave} {mem.s1}
    set_instance_parameter_value cpu {breakSlave} {None}
    set_instance_parameter_value cpu {setting_interruptControllerType} {Internal}
    set_instance_parameter_value cpu {setting_branchpredictiontype} {Dynamic}
    set_instance_parameter_value cpu {setting_bhtPtrSz} {8}
    set_instance_parameter_value cpu {cpuArchRev} {1}
    set_instance_parameter_value cpu {mul_shift_choice} {0}
    set_instance_parameter_value cpu {mul_32_impl} {2}
    set_instance_parameter_value cpu {mul_64_impl} {0}
    set_instance_parameter_value cpu {shift_rot_impl} {1}
    set_instance_parameter_value cpu {dividerType} {no_div}
    set_instance_parameter_value cpu {mpu_minInstRegionSize} {12}
    set_instance_parameter_value cpu {mpu_minDataRegionSize} {12}
    set_instance_parameter_value cpu {mmu_uitlbNumEntries} {4}
    set_instance_parameter_value cpu {mmu_udtlbNumEntries} {6}
    set_instance_parameter_value cpu {mmu_tlbPtrSz} {7}
    set_instance_parameter_value cpu {mmu_tlbNumWays} {16}
    set_instance_parameter_value cpu {mmu_processIDNumBits} {8}
    set_instance_parameter_value cpu {impl} {Fast}
    set_instance_parameter_value cpu {icache_size} {2048}
    set_instance_parameter_value cpu {fa_cache_line} {2}
    set_instance_parameter_value cpu {fa_cache_linesize} {0}
    set_instance_parameter_value cpu {icache_tagramBlockType} {Automatic}
    set_instance_parameter_value cpu {icache_ramBlockType} {Automatic}
    set_instance_parameter_value cpu {icache_numTCIM} {0}
    set_instance_parameter_value cpu {icache_burstType} {None}
    set_instance_parameter_value cpu {dcache_bursts} {false}
    set_instance_parameter_value cpu {dcache_victim_buf_impl} {ram}
    set_instance_parameter_value cpu {dcache_size} {0}
    set_instance_parameter_value cpu {dcache_tagramBlockType} {Automatic}
    set_instance_parameter_value cpu {dcache_ramBlockType} {Automatic}
    set_instance_parameter_value cpu {dcache_numTCDM} {0}
    set_instance_parameter_value cpu {setting_exportvectors} {0}
    set_instance_parameter_value cpu {setting_usedesignware} {0}
    set_instance_parameter_value cpu {setting_ecc_present} {0}
    set_instance_parameter_value cpu {setting_ic_ecc_present} {1}
    set_instance_parameter_value cpu {setting_rf_ecc_present} {1}
    set_instance_parameter_value cpu {setting_mmu_ecc_present} {1}
    set_instance_parameter_value cpu {setting_dc_ecc_present} {1}
    set_instance_parameter_value cpu {setting_itcm_ecc_present} {1}
    set_instance_parameter_value cpu {setting_dtcm_ecc_present} {1}
    set_instance_parameter_value cpu {regfile_ramBlockType} {Automatic}
    set_instance_parameter_value cpu {ocimem_ramBlockType} {Automatic}
    set_instance_parameter_value cpu {ocimem_ramInit} {0}
    set_instance_parameter_value cpu {mmu_ramBlockType} {Automatic}
    set_instance_parameter_value cpu {bht_ramBlockType} {Automatic}
    set_instance_parameter_value cpu {cdx_enabled} {0}
    set_instance_parameter_value cpu {mpx_enabled} {0}
    set_instance_parameter_value cpu {debug_enabled} {1}
    set_instance_parameter_value cpu {debug_triggerArming} {1}
    set_instance_parameter_value cpu {debug_debugReqSignals} {0}
    set_instance_parameter_value cpu {debug_assignJtagInstanceID} {0}
    set_instance_parameter_value cpu {debug_jtagInstanceID} {0}
    set_instance_parameter_value cpu {debug_OCIOnchipTrace} {_128}
    set_instance_parameter_value cpu {debug_hwbreakpoint} {0}
    set_instance_parameter_value cpu {debug_datatrigger} {0}
    set_instance_parameter_value cpu {debug_traceType} {none}
    set_instance_parameter_value cpu {debug_traceStorage} {onchip_trace}
    set_instance_parameter_value cpu {master_addr_map} {0}
    set_instance_parameter_value cpu {instruction_master_paddr_base} {0}
    set_instance_parameter_value cpu {instruction_master_paddr_size} {0.0}
    set_instance_parameter_value cpu {flash_instruction_master_paddr_base} {0}
    set_instance_parameter_value cpu {flash_instruction_master_paddr_size} {0.0}
    set_instance_parameter_value cpu {data_master_paddr_base} {0}
    set_instance_parameter_value cpu {data_master_paddr_size} {0.0}
    set_instance_parameter_value cpu {tightly_coupled_instruction_master_0_paddr_base} {0}
    set_instance_parameter_value cpu {tightly_coupled_instruction_master_0_paddr_size} {0.0}
    set_instance_parameter_value cpu {tightly_coupled_instruction_master_1_paddr_base} {0}
    set_instance_parameter_value cpu {tightly_coupled_instruction_master_1_paddr_size} {0.0}
    set_instance_parameter_value cpu {tightly_coupled_instruction_master_2_paddr_base} {0}
    set_instance_parameter_value cpu {tightly_coupled_instruction_master_2_paddr_size} {0.0}
    set_instance_parameter_value cpu {tightly_coupled_instruction_master_3_paddr_base} {0}
    set_instance_parameter_value cpu {tightly_coupled_instruction_master_3_paddr_size} {0.0}
    set_instance_parameter_value cpu {tightly_coupled_data_master_0_paddr_base} {0}
    set_instance_parameter_value cpu {tightly_coupled_data_master_0_paddr_size} {0.0}
    set_instance_parameter_value cpu {tightly_coupled_data_master_1_paddr_base} {0}
    set_instance_parameter_value cpu {tightly_coupled_data_master_1_paddr_size} {0.0}
    set_instance_parameter_value cpu {tightly_coupled_data_master_2_paddr_base} {0}
    set_instance_parameter_value cpu {tightly_coupled_data_master_2_paddr_size} {0.0}
    set_instance_parameter_value cpu {tightly_coupled_data_master_3_paddr_base} {0}
    set_instance_parameter_value cpu {tightly_coupled_data_master_3_paddr_size} {0.0}
    set_instance_parameter_value cpu {instruction_master_high_performance_paddr_base} {0}
    set_instance_parameter_value cpu {instruction_master_high_performance_paddr_size} {0.0}
    set_instance_parameter_value cpu {data_master_high_performance_paddr_base} {0}
    set_instance_parameter_value cpu {data_master_high_performance_paddr_size} {0.0}

    add_instance jtagUart altera_avalon_jtag_uart 15.1
    set_instance_parameter_value jtagUart {allowMultipleConnections} {0}
    set_instance_parameter_value jtagUart {hubInstanceID} {0}
    set_instance_parameter_value jtagUart {readBufferDepth} {64}
    set_instance_parameter_value jtagUart {readIRQThreshold} {8}
    set_instance_parameter_value jtagUart {simInputCharacterStream} {}
    set_instance_parameter_value jtagUart {simInteractiveOptions} {NO_INTERACTIVE_WINDOWS}
    set_instance_parameter_value jtagUart {useRegistersForReadBuffer} {0}
    set_instance_parameter_value jtagUart {useRegistersForWriteBuffer} {0}
    set_instance_parameter_value jtagUart {useRelativePathForSimFile} {0}
    set_instance_parameter_value jtagUart {writeBufferDepth} {64}
    set_instance_parameter_value jtagUart {writeIRQThreshold} {8}

    add_instance mem altera_avalon_onchip_memory2 15.1
    set_instance_parameter_value mem {allowInSystemMemoryContentEditor} {0}
    set_instance_parameter_value mem {blockType} {AUTO}
    set_instance_parameter_value mem {dataWidth} {32}
    set_instance_parameter_value mem {dualPort} {0}
    set_instance_parameter_value mem {initMemContent} {1}
    set_instance_parameter_value mem {initializationFileName} {onchip_mem.hex}
    set_instance_parameter_value mem {instanceID} {NONE}
    set_instance_parameter_value mem {memorySize} {40960.0}
    set_instance_parameter_value mem {readDuringWriteMode} {DONT_CARE}
    set_instance_parameter_value mem {simAllowMRAMContentsFile} {0}
    set_instance_parameter_value mem {simMemInitOnlyFilename} {0}
    set_instance_parameter_value mem {singleClockOperation} {0}
    set_instance_parameter_value mem {slave1Latency} {1}
    set_instance_parameter_value mem {slave2Latency} {1}
    set_instance_parameter_value mem {useNonDefaultInitFile} {0}
    set_instance_parameter_value mem {copyInitFile} {0}
    set_instance_parameter_value mem {useShallowMemBlocks} {0}
    set_instance_parameter_value mem {writable} {1}
    set_instance_parameter_value mem {ecc_enabled} {0}
    set_instance_parameter_value mem {resetrequest_enabled} {1}

    add_instance sysid altera_avalon_sysid_qsys 15.1
    set_instance_parameter_value sysid {id} {5465204}

    add_instance timestampTimer altera_avalon_timer 15.1
    set_instance_parameter_value timestampTimer {alwaysRun} {0}
    set_instance_parameter_value timestampTimer {counterSize} {32}
    set_instance_parameter_value timestampTimer {fixedPeriod} {0}
    set_instance_parameter_value timestampTimer {period} {1}
    set_instance_parameter_value timestampTimer {periodUnits} {MSEC}
    set_instance_parameter_value timestampTimer {resetOutput} {0}
    set_instance_parameter_value timestampTimer {snapshot} {1}
    set_instance_parameter_value timestampTimer {timeoutPulseOutput} {0}
    set_instance_parameter_value timestampTimer {watchdogPulse} {2}

    # connections and connection parameters
    add_connection cpu.data_master acDriver.acAmmSlv avalon
    set_connection_parameter_value cpu.data_master/acDriver.acAmmSlv arbitrationPriority {1}
    set_connection_parameter_value cpu.data_master/acDriver.acAmmSlv baseAddress {0x00021030}
    set_connection_parameter_value cpu.data_master/acDriver.acAmmSlv defaultConnection {0}

    add_connection cpu.data_master jtagUart.avalon_jtag_slave avalon
    set_connection_parameter_value cpu.data_master/jtagUart.avalon_jtag_slave arbitrationPriority {1}
    set_connection_parameter_value cpu.data_master/jtagUart.avalon_jtag_slave baseAddress {0x00021028}
    set_connection_parameter_value cpu.data_master/jtagUart.avalon_jtag_slave defaultConnection {0}

    add_connection cpu.data_master sysid.control_slave avalon
    set_connection_parameter_value cpu.data_master/sysid.control_slave arbitrationPriority {1}
    set_connection_parameter_value cpu.data_master/sysid.control_slave baseAddress {0x00021020}
    set_connection_parameter_value cpu.data_master/sysid.control_slave defaultConnection {0}

    add_connection cpu.data_master cpu.debug_mem_slave avalon
    set_connection_parameter_value cpu.data_master/cpu.debug_mem_slave arbitrationPriority {1}
    set_connection_parameter_value cpu.data_master/cpu.debug_mem_slave baseAddress {0x00020800}
    set_connection_parameter_value cpu.data_master/cpu.debug_mem_slave defaultConnection {0}

    add_connection cpu.data_master acDriver.i2cAmmSlv avalon
    set_connection_parameter_value cpu.data_master/acDriver.i2cAmmSlv arbitrationPriority {1}
    set_connection_parameter_value cpu.data_master/acDriver.i2cAmmSlv baseAddress {0x00021038}
    set_connection_parameter_value cpu.data_master/acDriver.i2cAmmSlv defaultConnection {0}

    add_connection cpu.data_master mem.s1 avalon
    set_connection_parameter_value cpu.data_master/mem.s1 arbitrationPriority {1}
    set_connection_parameter_value cpu.data_master/mem.s1 baseAddress {0x00010000}
    set_connection_parameter_value cpu.data_master/mem.s1 defaultConnection {0}

    add_connection cpu.data_master timestampTimer.s1 avalon
    set_connection_parameter_value cpu.data_master/timestampTimer.s1 arbitrationPriority {1}
    set_connection_parameter_value cpu.data_master/timestampTimer.s1 baseAddress {0x00021000}
    set_connection_parameter_value cpu.data_master/timestampTimer.s1 defaultConnection {0}

    add_connection cpu.instruction_master cpu.debug_mem_slave avalon
    set_connection_parameter_value cpu.instruction_master/cpu.debug_mem_slave arbitrationPriority {1}
    set_connection_parameter_value cpu.instruction_master/cpu.debug_mem_slave baseAddress {0x00020800}
    set_connection_parameter_value cpu.instruction_master/cpu.debug_mem_slave defaultConnection {0}

    add_connection cpu.instruction_master mem.s1 avalon
    set_connection_parameter_value cpu.instruction_master/mem.s1 arbitrationPriority {1}
    set_connection_parameter_value cpu.instruction_master/mem.s1 baseAddress {0x00010000}
    set_connection_parameter_value cpu.instruction_master/mem.s1 defaultConnection {0}

    add_connection clk.clk cpu.clk clock

    add_connection clk.clk jtagUart.clk clock

    add_connection clk.clk sysid.clk clock

    add_connection clk.clk timestampTimer.clk clock

    add_connection clk.clk mem.clk1 clock

    add_connection clk.clk acDriver.i2cClk clock

    add_connection clk.clk audioPll.refclk clock

    add_connection audioPll.outclk0 acDriver.acClk clock

    add_connection cpu.irq acDriver.i2cIrq interrupt
    set_connection_parameter_value cpu.irq/acDriver.i2cIrq irqNumber {2}

    add_connection cpu.irq jtagUart.irq interrupt
    set_connection_parameter_value cpu.irq/jtagUart.irq irqNumber {0}

    add_connection cpu.irq timestampTimer.irq interrupt
    set_connection_parameter_value cpu.irq/timestampTimer.irq irqNumber {1}

    add_connection clk.clk_reset acDriver.acReset reset

    add_connection clk.clk_reset acDriver.i2cReset reset

    add_connection clk.clk_reset jtagUart.reset reset

    add_connection clk.clk_reset cpu.reset reset

    add_connection clk.clk_reset sysid.reset reset

    add_connection clk.clk_reset timestampTimer.reset reset

    add_connection clk.clk_reset audioPll.reset reset

    add_connection clk.clk_reset mem.reset1 reset

    add_connection cpu.debug_reset_request acDriver.acReset reset

    add_connection cpu.debug_reset_request acDriver.i2cReset reset

    add_connection cpu.debug_reset_request cpu.reset reset

    add_connection cpu.debug_reset_request jtagUart.reset reset

    add_connection cpu.debug_reset_request sysid.reset reset

    add_connection cpu.debug_reset_request timestampTimer.reset reset

    add_connection cpu.debug_reset_request mem.reset1 reset

    # exported interfaces
    add_interface audiocodeccontrol conduit end
    set_interface_property audiocodeccontrol EXPORT_OF acDriver.audioCodecControl
    add_interface audiointerface conduit end
    set_interface_property audiointerface EXPORT_OF acDriver.audioInterface
    add_interface clk clock sink
    set_interface_property clk EXPORT_OF clk.clk_in
    add_interface i2cinterface conduit end
    set_interface_property i2cinterface EXPORT_OF acDriver.i2cInterface
    add_interface reset reset sink
    set_interface_property reset EXPORT_OF clk.clk_in_reset

    # interconnect requirements
    set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {HANDSHAKE}
    set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {1}
    set_interconnect_requirement {$system} {qsys_mm.enableEccProtection} {FALSE}
    set_interconnect_requirement {$system} {qsys_mm.insertDefaultSlave} {FALSE}
}
