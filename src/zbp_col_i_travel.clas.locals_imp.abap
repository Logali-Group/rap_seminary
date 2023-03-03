class lhc_Travel definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_features for instance features
      importing keys request requested_features for Travel result result.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for Travel result result.

    methods acceptTravel for modify
      importing keys for action Travel~acceptTravel result result.

    methods createTravelByTemplate for modify
      importing keys for action Travel~createTravelByTemplate result result.

    methods rejectTravel for modify
      importing keys for action Travel~rejectTravel result result.

    methods validateCustomer for validate on save
      importing keys for Travel~validateCustomer.

    methods validateDate for validate on save
      importing keys for Travel~validateDate.

    methods validateStatus for validate on save
      importing keys for Travel~validateStatus.

*    methods calculateTravelKey for determine on save
*      importing keys for Travel~calculateTravelKey.

endclass.

class lhc_Travel implementation.

  method get_instance_features.

    read entities of zcol_i_travel
      in local mode
      entity Travel
      fields ( TravelId
               OverallStatus )
       with value #( for <row_key> in keys ( %key = <row_key>-%key ) )
       result data(lt_entity_travel).


    result = value #( for <ls_travel> in lt_entity_travel (
                             %key     = <ls_travel>-TravelId
                             %field-TravelId  = if_abap_behv=>fc-f-read_only
                             %field-OverallStatus  = if_abap_behv=>fc-f-read_only
                             %action-acceptTravel = cond #( when <ls_travel>-OverallStatus = 'A'
                                                              then if_abap_behv=>fc-o-disabled
                                                              else if_abap_behv=>fc-o-enabled )
                             %action-rejectTravel = cond #( when <ls_travel>-OverallStatus = 'X'
                                                              then if_abap_behv=>fc-o-disabled
                                                              else if_abap_behv=>fc-o-enabled )
                             ) ).


  endmethod.

  method get_instance_authorizations.

    data(lv_auth) = cond #( when cl_abap_context_info=>get_user_technical_name(  ) eq 'CB9980010502'
                              then if_abap_behv=>auth-allowed
                              else if_abap_behv=>auth-unauthorized ).

    loop at keys assigning field-symbol(<ls_keys>).
      append initial line to result assigning field-symbol(<ls_result>).
      <ls_result> = value #( %key = <ls_keys>-%key
                             %op-%update                    = lv_auth
                             %delete                        = lv_auth
                             %action-createTravelByTemplate = lv_auth
                             %action-acceptTravel           = lv_auth
                             %action-rejectTravel           = lv_auth
                             %assoc-_Booking                = lv_auth ).
    endloop.


  endmethod.

  method acceptTravel.

    modify entities of zcol_i_travel
       in local mode entity Travel
       update
       fields ( OverallStatus )
       with  value #( for <key> in keys ( TravelId = <key>-TravelId
                                           OverallStatus = 'A' ) )
       failed failed
       reported reported.

    check failed is initial.

    read entities of zcol_i_travel
         in local mode
         entity Travel
         fields ( AgencyId
                  CustomerId
                  BeginDate
                  EndDate
                  BookingFee
                  TotalPrice
                  CurrencyCode
                  Description
                  OverallStatus
                  CreatedBy
                  CreatedAt
                  LastChangedBy
                  LastChangedAt )
          with value #( for <row_key> in keys ( TravelId = <row_key>-TravelId ) )
          result data(lt_entity_travel)
          failed failed.

    result = value #( for <fs_travel> in lt_entity_travel ( TravelId = <fs_travel>-TravelId
                                                            %param   = <fs_travel> ) ).

    loop at lt_entity_travel assigning field-symbol(<ls_travel>).
      append value #( TravelId = <ls_travel>-TravelId
                      %msg = new_message( id                      = 'ZCOL_MSG'
                                          number                  = '001'
                                          v1                      = shift_left( val = <ls_travel>-TravelId sub = '0' )
                                          severity                = if_abap_behv_message=>severity-success )
                      %element-OverallStatus = if_abap_behv=>mk-on ) to reported-travel.
    endloop.


  endmethod.

  method createTravelByTemplate.

*  keys[ 1 ]-
*  result[ 1 ]-
*  mapped-
*  failed-
*  reported-
*  EML - Entity Manipulation Language

    read entities of zcol_i_travel "RAP BO = CDS + Behavior
         in local mode
         entity Travel
         fields ( TravelId         "ALL FIELDS
                  AgencyId
                  CustomerId
                  BookingFee
                  TotalPrice
                  CurrencyCode )
          with value #( for <row_key> in keys ( %key = <row_key>-%key ) )
          result data(lt_entity_travel) "Table contains all data
*          failed data(failed_data)
          failed failed  "implicit param - if any failed - get data
*          reported data(reported_data)
          reported reported. "if message are raised in BO implemenetation

    check failed is initial.

    data(lv_today) = cl_abap_context_info=>get_system_date( ).

    data lt_create type table for create zcol_i_travel\\Travel.

    select max( travel_id ) from zcol_travel into @data(lv_travel_id).

    lt_create = value #( for <row> in lt_entity_travel index into idx
                            ( TravelId      = lv_travel_id + idx
                              AgencyId      = <row>-AgencyId
                              CustomerId    = <row>-CustomerId
                              BeginDate     = lv_today
                              EndDate       = lv_today + 30
                              BookingFee    = <row>-BookingFee
                              TotalPrice    = <row>-TotalPrice
                              CurrencyCode  = <row>-CurrencyCode
                              description    = 'Comments here'
                              OverallStatus = 'O' ) ).

    modify entities of zcol_i_travel
        in local mode entity Travel
        create
        fields ( TravelId
                 AgencyId
                 CustomerId
                 BeginDate
                 EndDate
                 BookingFee
                 TotalPrice
                 CurrencyCode
                 Description
                 OverallStatus )
         with lt_create
         mapped mapped
         failed failed
         reported reported.

    result = value #( for <row_create> in lt_create index into idx
                        ( %cid_ref = keys[ idx ]-%cid_ref
                          %key     = keys[ idx ]-TravelId
                          %param   = corresponding #( <row_create> ) ) ).

  endmethod.

  method rejectTravel.

    modify entities of zcol_i_travel
       in local mode entity Travel
       update
       fields ( OverallStatus )
       with  value #( for <key> in keys ( TravelId = <key>-TravelId
                                           OverallStatus = 'X' ) )
       failed failed
       reported reported.

    check failed is initial.

    read entities of zcol_i_travel
         in local mode
         entity Travel
         fields ( AgencyId
                  CustomerId
                  BeginDate
                  EndDate
                  BookingFee
                  TotalPrice
                  CurrencyCode
                  Description
                  OverallStatus
                  CreatedBy
                  CreatedAt
                  LastChangedBy
                  LastChangedAt )
          with value #( for <row_key> in keys ( TravelId = <row_key>-TravelId ) )
          result data(lt_entity_travel)
          failed failed.

    result = value #( for <fs_travel> in lt_entity_travel ( TravelId = <fs_travel>-TravelId
                                                            %param   = <fs_travel> ) ).

    loop at lt_entity_travel assigning field-symbol(<ls_travel>).
      append value #( TravelId = <ls_travel>-TravelId
                      %msg = new_message( id                      = 'ZCOL_MSG'
                                          number                  = '002'
                                          v1                      = shift_left( val = <ls_travel>-TravelId sub = '0' )
                                          severity                = if_abap_behv_message=>severity-success )
                     %element-OverallStatus = if_abap_behv=>mk-on ) to reported-travel.
    endloop.

  endmethod.

  method validateCustomer.

    read entities of zcol_i_travel
         in local mode
         entity Travel
         fields ( CustomerId )
         with corresponding #(  keys )
         result data(lt_travel).

    data lt_customer type sorted table of /dmo/customer with unique key client customer_id.

    lt_customer = corresponding #( lt_travel discarding duplicates
                                             mapping customer_id = CustomerId
                                             except * ).

    delete lt_customer where customer_id is initial.

    if not lt_customer is  initial.
      select from @lt_customer as it_cust
             inner join /dmo/customer as bd_cust on it_cust~customer_id eq bd_cust~customer_id
             fields it_cust~customer_id
             into table @data(lt_customer_db)
             ##db_feature_mode[itabs_in_from_clause] ##itab_db_select..
    endif.

    loop at lt_travel assigning field-symbol(<ls_travel>).
      if <ls_travel>-CustomerId is initial
         or not line_exists( lt_customer_db[ customer_id = <ls_travel>-CustomerId ] ).

        append value #(  TravelId = <ls_travel>-TravelId ) to failed-travel.
        append value #(  TravelId = <ls_travel>-TravelId
                         %msg = new_message( id        = '/DMO/CM_FLIGHT_LEGAC'
                                             number    = '002'
                                             v1        = <ls_travel>-CustomerId
                                             severity  = if_abap_behv_message=>severity-error )
                         %element-CustomerId = if_abap_behv=>mk-on ) to reported-travel.
      endif.
    endloop.

  endmethod.

  method validateDate.

*    read entity zcol_i_travel\\Travel
    read entities of zcol_i_travel
         in local mode
         entity Travel
         fields ( BeginDate EndDate )
*         with value #( for <root_key> in keys ( %key = <root_key> ) )
         with corresponding #(  keys )
         result data(lt_travel).

    loop at lt_travel assigning field-symbol(<ls_travel_result>).

      if <ls_travel_result>-EndDate < <ls_travel_result>-BeginDate.

        append value #( %key        = <ls_travel_result>-%key
                        TravelId   = <ls_travel_result>-TravelId ) to failed-travel.

        append value #( %key     = <ls_travel_result>-%key
                        %msg     = new_message( id       = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgid
                                                number   = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgno
                                                v1       = <ls_travel_result>-BeginDate
                                                v2       = <ls_travel_result>-EndDate
                                                v3       = <ls_travel_result>-TravelId
                                                severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate   = if_abap_behv=>mk-on ) to reported-travel.

      elseif <ls_travel_result>-BeginDate < cl_abap_context_info=>get_system_date( ).

        append value #( %key        = <ls_travel_result>-%key
                        TravelId   = <ls_travel_result>-TravelId ) to failed-travel.

        append value #( %key = <ls_travel_result>-%key
                        %msg = new_message( id       = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgid
                                            number   = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgno
                                            severity = if_abap_behv_message=>severity-error )
                                            %element-BeginDate = if_abap_behv=>mk-on
*                                            %element-EndDate   = if_abap_behv=>mk-on
                                            ) to reported-travel.
      endif.
    endloop.


  endmethod.

  method validateStatus.

    read entities of zcol_i_travel
         in local mode
         entity Travel
         fields ( OverallStatus )
         with corresponding #(  keys )
         result data(lt_travel).


    loop at lt_travel assigning field-symbol(<ls_travel>).
      case <ls_travel>-OverallStatus.
        when 'O'.  " Open
        when 'X'.  " Cancelled
        when 'A'.  " Accepted

        when others.
          append value #( %key = <ls_travel>-%key ) to failed-travel.

          append value #( %key = <ls_travel>-%key
                          %msg = new_message( id       = /dmo/cx_flight_legacy=>status_is_not_valid-msgid
                                              number   = /dmo/cx_flight_legacy=>status_is_not_valid-msgno
                                              v1       = <ls_travel>-OverallStatus
                                              severity = if_abap_behv_message=>severity-error )
                          %element-OverallStatus = if_abap_behv=>mk-on ) to reported-travel.
      endcase.
    endloop.

  endmethod.

*  method calculateTravelKey.

*    read entities of zcol_i_travel
*        in local mode
*        entity Travel
*        fields ( TravelId )
*        with corresponding #(  keys )
*         result data(lt_travel).
*
**    delete lt_travel where TravelId is not initial.
**
**    check lt_travel is not initial.
*
*    "Get max travelID
*    select single from zcol_travel fields max( travel_id ) into @data(lv_max_travelid).
*
*    "update involved instances
*    modify entities of zcol_i_travel
*           in local mode
*           entity Travel
*           update
*           fields ( TravelId )
*           with value #( for <row> in lt_travel index into i (
*                              %key     = <row>-%key
*                              TravelId = lv_max_travelid + i ) )
*     reported data(lt_reported).

*  endmethod.

endclass.

class lhc_Booking definition inheriting from cl_abap_behavior_handler.
  private section.

    methods calculateTotalFlightPrice for determine on modify
      importing keys for Booking~calculateTotalFlightPrice.

    methods validateStatus for validate on save
      importing keys for Booking~validateStatus.

endclass.

class lhc_Booking implementation.

  method calculateTotalFlightPrice.

    if keys is not initial.
      zcl_col_travel_helper=>calculate_price(
        it_travel_id = value #( for groups <booking> of booking_key in keys
                                    group by booking_key-TravelId
                                    without members ( <booking> ) ) ).
    endif.

  endmethod.

  method validateStatus.

    read entities of zcol_i_travel
         in local mode
         entity Booking
         fields ( TravelId )
         with corresponding #(  keys )
         result data(lt_travel).

    loop at lt_travel assigning field-symbol(<ls_travel>).

      case <ls_travel>-BookingStatus.
        when 'O'.  " Open
        when 'N'.  " New
        when 'X'.  " Cancelled
        when 'A'.  " Accepted
        when others.
          append value #( %key = <ls_travel>-%key ) to failed-travel.

          append value #( %key = <ls_travel>-%key
                          %msg = new_message( id       = /dmo/cx_flight_legacy=>status_is_not_valid-msgid
                                              number   = /dmo/cx_flight_legacy=>status_is_not_valid-msgno
                                              v1       = <ls_travel>-BookingStatus
                                              severity = if_abap_behv_message=>severity-error )
                          %element-OverallStatus       = if_abap_behv=>mk-on ) to reported-travel.
      endcase.

    endloop.

  endmethod.

endclass.

class lhc_BookingSupplement definition inheriting from cl_abap_behavior_handler.
  private section.

    methods calculateTotalFlightPrice for determine on modify
      importing keys for BookingSupplement~calculateTotalFlightPrice.

endclass.

class lhc_BookingSupplement implementation.

  method calculateTotalFlightPrice.

    if keys is not initial.
      zcl_col_travel_helper=>calculate_price(
        it_travel_id = value #( for groups <supplement> of supplement_key in keys
                                    group by supplement_key-TravelId
                                    without members ( <supplement> ) ) ).
    endif.

  endmethod.

endclass.

class lsc_ZCOL_I_TRAVEL definition inheriting from cl_abap_behavior_saver.
  protected section.

    methods save_modified redefinition.

    methods cleanup_finalize redefinition.

endclass.

class lsc_ZCOL_I_TRAVEL implementation.

  method save_modified.

**    data: lt_log type standard table of zcol_log.
**
**    data(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).
**
***    create-
***    delete-
***    update-
**
**    if not create-travel is initial.
**      lt_log = corresponding #( create-travel mapping travel_id = TravelId ).
**    elseif not update-travel is initial.
**      lt_log = corresponding #( update-travel mapping travel_id = TravelId ).
**    endif.
**
**    loop at lt_log assigning field-symbol(<ls_log_c>).
**      get time stamp field <ls_log_c>-created_at.
**
**      if not create-travel is initial.
**        <ls_log_c>-changing_operation = 'CREATE'.
**        read table create-travel
**             with table key entity
**             components TravelId = <ls_log_c>-travel_id
**             into data(ls_travel).
**      elseif not update-travel is initial.
**        <ls_log_c>-changing_operation = 'UPDATE'.
**        read table update-travel
**             with table key entity
**             components TravelId = <ls_log_c>-travel_id
**             into ls_travel.
**      endif.
**
**      if sy-subrc eq 0.
**        if ls_travel-%control-BookingFee eq cl_abap_behv=>flag_changed.
**          try.
**              <ls_log_c>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
**            catch cx_uuid_error into data(lx_uuid_error).
**              "handle exception
**              "lx_uuid_error->get_text(  ).
**          endtry.
**          <ls_log_c>-changed_field_name = 'BookingFee'.
**          <ls_log_c>-changed_value = ls_travel-BookingFee.
**          <ls_log_c>-user_mod = lv_user.
**        endif.
**      endif.
**
**    endloop.
**
**    delete lt_log where travel_id is initial.

*    if not lt_log is initial.
*      if not create-travel is initial or
*         not update-travel is initial.
*        modify zcol_log from table @lt_log.
*      endif.
*    endif.

* ****Supplements***with unmanaged save***

*    data lt_supplements type table of zcol_booksuppl.
*
*    if not create-bookingsupplement is initial.
*      lt_supplements = corresponding #( create-bookingsupplement mapping travel_id     = %control-TravelId
*                                                                         booking_id    = %control-BookingId
*                                                                         supplement_id = %control-SupplementId
*                                                                         price         = Price
*                                                                         currency_code = CurrencyCode ).
*      loop at lt_supplements assigning field-symbol(<ls_supplements>).
*        get time stamp field  <ls_supplements>-last_changed_at.
*      endloop.
*      insert zcol_booksuppl from table @lt_supplements.
*    endif.
*
*    if not update-bookingsupplement is initial.
*      lt_supplements = corresponding #( update-bookingsupplement mapping travel_id     = %control-TravelId
*                                                                         booking_id    = %control-BookingId
*                                                                         supplement_id = %control-SupplementId
*                                                                         price         = Price
*                                                                         currency_code = CurrencyCode ).
*      loop at lt_supplements assigning <ls_supplements>.
*        get time stamp field  <ls_supplements>-last_changed_at.
*      endloop.
*      update zcol_booksuppl from table @lt_supplements.
*    endif.
*
*    if not delete-bookingsupplement is initial.
*      lt_supplements = corresponding #( delete-bookingsupplement mapping travel_id     = TravelId
*                                                                         booking_id    = BookingId
*                                                                         supplement_id = BookingSupplementId ).
*      delete zcol_booksuppl from table @lt_supplements.
*    endif.

  endmethod.

  method cleanup_finalize.
  endmethod.

endclass.
