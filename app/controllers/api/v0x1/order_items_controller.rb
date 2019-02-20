module Api
  module V0x1
    class OrderItemsController < ApplicationController
      include Api::V0x1::Mixins::IndexMixin

      def index
        if params[:order_id]
          collection(Order.find(params.require(:order_id)).order_items)
        else
          collection(OrderItem.all)
        end
      end

      def create
        so = ServiceCatalog::AddToOrder.new(params)
        render :json => so.process.order
      end

      def show
        if params[:order_id] && params[:order_item_id]
          render :json => Order.find(params.require(:order_id)).order_items.find(params.require(:order_item_id))
        else
          render :json => OrderItem.find(params.require(:order_item_id))
        end
      end
    end
  end
end
