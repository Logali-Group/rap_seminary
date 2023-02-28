@EndUserText.label: 'Booking Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZCOL_C_BOOKING
  ///provider contract transactional_query
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
      _Travel         : redirected to parent ZCOL_C_TRAVEL,
      _BookSupplement : redirected to composition child ZCOL_C_BOOKSUPPL,
      _Customer,
      _Connection,
      _Carrier
}
