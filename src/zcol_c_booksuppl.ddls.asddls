@EndUserText.label: 'Booking Supplement Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZCOL_C_BOOKSUPPL
  as projection on zcol_i_booksuppl
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: ['SupplementDescription']
      SupplementId,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,

      /* Associations */
      _Travel  : redirected to ZCOL_C_TRAVEL,   //????
      _Booking : redirected to parent ZCOL_C_BOOKING,
      _Product,
      _SupplementText
}
