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

endclass.

class lhc_Travel implementation.

  method get_instance_features.
  endmethod.

  method get_instance_authorizations.
  endmethod.

  method acceptTravel.
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
        create fields ( TravelId
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
  endmethod.

  method validateCustomer.
  endmethod.

  method validateDate.
  endmethod.

  method validateStatus.
  endmethod.

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
  endmethod.

  method validateStatus.
  endmethod.

endclass.

class lhc_BookingSupplement definition inheriting from cl_abap_behavior_handler.
  private section.

    methods calculateTotalFlightPrice for determine on modify
      importing keys for BookingSupplement~calculateTotalFlightPrice.

endclass.

class lhc_BookingSupplement implementation.

  method calculateTotalFlightPrice.
  endmethod.

endclass.

class lsc_ZCOL_I_TRAVEL definition inheriting from cl_abap_behavior_saver.
  protected section.

    methods save_modified redefinition.

    methods cleanup_finalize redefinition.

endclass.

class lsc_ZCOL_I_TRAVEL implementation.

  method save_modified.
  endmethod.

  method cleanup_finalize.
  endmethod.

endclass.
