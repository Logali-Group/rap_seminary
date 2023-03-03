class zcl_col_virt_elem definition
  public
  final
  create public .

  public section.
    interfaces if_sadl_exit_calc_element_read.
  protected section.
  private section.
endclass.



class zcl_col_virt_elem implementation.

  method if_sadl_exit_calc_element_read~get_calculation_info.

    if iv_entity = 'ZCOL_C_TRAVEL'.
      loop at it_requested_calc_elements assigning field-symbol(<fs_calc_element>).
        if <fs_calc_element> = 'DISCOUNTPRICE'.
          append 'TOTALPRICE' to et_requested_orig_elements.
        endif.
      endloop.
    else.
      return.
    endif.

  endmethod.

  method if_sadl_exit_calc_element_read~calculate.

    data lt_original_data type standard table of zcol_c_travel with default key.

    lt_original_data = corresponding #( it_original_data ).

    loop at lt_original_data assigning field-symbol(<fs_original_data>)
            where TotalPrice ne 0.
      <fs_original_data>-DiscountPrice = <fs_original_data>-TotalPrice * '0.9'.
    endloop.

    ct_calculated_data = corresponding #( lt_original_data ).

endmethod.

endclass.
