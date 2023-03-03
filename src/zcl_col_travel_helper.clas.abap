class zcl_col_travel_helper definition
  public
  final
  create public .

  public section.

    types tt_travel_id type table of /dmo/travel_id.

    class-methods calculate_price importing it_travel_id type tt_travel_id.

  protected section.
  private section.
endclass.

class zcl_col_travel_helper implementation.

  method calculate_price.

    data: total_book_price_by_trav_curr  type /dmo/total_price,
          total_suppl_price_by_trav_curr type /dmo/total_price.

    if it_travel_id is initial.
      return.
    endif.

    read entities of zcol_i_travel
         entity Travel
         from value #( for <lv_travel_id> in it_travel_id (
                                TravelId = <lv_travel_id>
                                %control-CurrencyCode = if_abap_behv=>mk-on ) )
         result  data(lt_read_travel).

    read entities of zcol_i_travel
         entity Travel by \_Booking
         from value #( for <lv_travel_id> in it_travel_id (
                        TravelId = <lv_travel_id>
                        %control-FlightPrice   = if_abap_behv=>mk-on
                        %control-BookingStatus = if_abap_behv=>mk-on
                        %control-CurrencyCode  = if_abap_behv=>mk-on ) )
         result data(lt_read_booking_by_travel).

    loop at lt_read_booking_by_travel
         into data(ls_booking)
         group by ls_booking-TravelId
         into data(ls_travel_key).

      assign lt_read_travel[ key entity components TravelId = ls_travel_key ]
            to field-symbol(<ls_travel>).

      loop at group ls_travel_key into data(ls_booking_result)
        group by ls_booking_result-CurrencyCode into data(lv_curr).

        total_book_price_by_trav_curr = 0.

        loop at group lv_curr into data(ls_booking_line).
          total_book_price_by_trav_curr   += ls_booking_line-FlightPrice.
        endloop.

        if lv_curr  = <ls_travel>-CurrencyCode.
          <ls_travel>-TotalPrice += total_book_price_by_trav_curr.
        else.
          /dmo/cl_flight_amdp=>convert_currency(
            exporting
              iv_amount               = total_book_price_by_trav_curr
              iv_currency_code_source = lv_curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            importing
              ev_amount               = data(total_book_price_per_curr) ).
          <ls_travel>-TotalPrice += total_book_price_per_curr.
        endif.
      endloop.
    endloop.

    read entities of zcol_i_travel
             entity Booking by \_BookSupplement
                   from value #( for ls_travel in lt_read_booking_by_travel (
                          TravelId              = ls_travel-TravelId
                          BookingId             = ls_travel-BookingId
                          %control-Price        = if_abap_behv=>mk-on
                          %control-CurrencyCode = if_abap_behv=>mk-on ) )
          result  data(lt_read_booksuppl).

    loop at lt_read_booksuppl into data(ls_booking_suppl)
      group by ls_booking_suppl-TravelId into ls_travel_key.

      assign lt_read_travel[ key entity components TravelId = ls_travel_key ] to <ls_travel>.

      loop at group ls_travel_key into data(ls_bookingsuppl_result)
        group by ls_bookingsuppl_result-CurrencyCode into lv_curr.

        total_suppl_price_by_trav_curr = 0.

        loop at group lv_curr into data(ls_booking_suppl2).
          total_suppl_price_by_trav_curr    += ls_booking_suppl2-price.
        endloop.

        if lv_curr  = <ls_travel>-CurrencyCode.
          <ls_travel>-TotalPrice    += total_suppl_price_by_trav_curr.
        else.
          /dmo/cl_flight_amdp=>convert_currency( exporting iv_amount               = total_suppl_price_by_trav_curr
                                                           iv_currency_code_source = lv_curr
                                                           iv_currency_code_target = <ls_travel>-CurrencyCode
                                                           iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
                                                 importing ev_amount               = data(total_suppl_price_per_curr) ).
          <ls_travel>-TotalPrice     += total_suppl_price_per_curr.
        endif.
      endloop.
    endloop.

    modify entities of zcol_i_travel
           entity Travel
           update
           fields ( TotalPrice )
           with value #( for travel in lt_read_travel (
                            TravelId            = travel-TravelId
                            TotalPrice          = travel-TotalPrice
                            %control-TotalPrice = if_abap_behv=>mk-on ) )
           failed data(lt_failed)
           reported data(lt_reported).

  endmethod.
endclass.

