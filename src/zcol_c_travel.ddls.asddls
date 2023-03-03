@EndUserText.label: 'Travel Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZCOL_C_TRAVEL
  provider contract transactional_query
  as projection on zcol_i_travel
{
  key     TravelId,
          AgencyId,
          @ObjectModel.text.element: ['AgencyName']
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
          CreatedAt,
          LastChangedBy,
          LastChangedAt,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @EndUserText.label: 'Discount'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_COL_VIRT_ELEM'
  virtual DiscountPrice : /dmo/total_price,
          /* Associations */
          _Booking : redirected to composition child ZCOL_C_BOOKING,
          _Agency,
          //_Currency,
          _Customer
}
