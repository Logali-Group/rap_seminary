class zcl_col_commit_entities definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.
  protected section.
  private section.
endclass.



class zcl_col_commit_entities implementation.
  method if_oo_adt_classrun~main.

    data(lv_travel_id)     = '00000054'. " Valid travel ID
    data(lv_description)   = 'Changed Travel Agency'.
    data(lv_new_agency_id) = '070017'.
    data(lv_total_price)   = '5235.50'. " Valid agency ID

    modify entity zcol_i_travel
           update
           fields ( AgencyId Description )
           with value #( ( TravelId    = lv_travel_id
                           AgencyId    = lv_new_agency_id
                           Description = lv_description
                           TotalPrice  = lv_total_price ) )
           failed data(ls_failed)
           reported data(ls_reported).

    check ls_failed is initial.

    read entity zcol_i_travel
         fields (  AgencyId Description )
         with value #( ( TravelId = lv_travel_id ) )
         result data(lt_received_travel_data)
         failed ls_failed.

    out->write( lt_received_travel_data ).

    commit entities.

    if sy-subrc = 0.
      out->write( 'Successful COMMIT!' ).
    else.
      out->write( 'COMMIT failed!' ).
    endif.

  endmethod.

endclass.
