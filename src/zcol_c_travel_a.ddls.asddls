@EndUserText.label: 'Travel Projection Approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZCOL_C_TRAVEL_A
  provider contract transactional_query
  as projection on zcol_i_travel
{
  key TravelId,
      @ObjectModel.text.element: ['AgencyName']
      AgencyId,
      _Agency.Name       as AgencyName,
      @ObjectModel.text.element: ['CustomerName']
      CustomerId,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      CreatedBy,
      Createdat,
      LastChangedBy,
      LastChangedAt,

      /* Associations */
      _Booking : redirected to composition child ZCOL_C_BOOKING_A,
      _Agency,
      _Customer
}
