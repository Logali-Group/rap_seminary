@EndUserText.label: 'Booking Projection Approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZCOL_C_BOOKING_A
  as projection on zcol_i_booking
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      @ObjectModel.text.element: ['CarrierName']
      CarrierId,
      _Carrier.Name as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      
      /* Associations */
      _Travel : redirected to parent ZCOL_C_TRAVEL_A,
      _Customer,
      _Carrier
}
