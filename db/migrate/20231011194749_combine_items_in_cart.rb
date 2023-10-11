class CombineItemsInCart < ActiveRecord::Migration[7.1]
  
  def up
    # замените несколько позиций для одного товара в корзине на 
    # отдельный элемент
    Cart.all.each do |cart|
      # подсчитайте количество каждого товара в корзине      
      sums = cart.line_items.group(:product_id).sum(:quantity)

      sums.each do |product_id, quantity| 
        if quantity > 1
          # удалить отдельные элементы
          cart.line_items.where(product_id: product_id).delete_all

          # заменить одним элементом
          item = cart.line_items.build(product_id: product_id) 
          item.quantity = quantity
          item.save!
        end 
      end
    end
  end

  def down
    # разделить товары с quantity>1 на несколько позиций
    LineItem.where("quantity>1").each do |line_item| 
      # добавление отдельных элементов
      line_item.quantity.times do
        LineItem.create(
          cart_id: line_item.cart_id, 
          product_id: line_item.product_id, 
          quantity: 1
        )
      end

      # удалить исходный элемент
      line_item.destroy 
    end
  end

end
