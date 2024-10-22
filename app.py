from MySQLdb import IntegrityError
from flask import Flask, render_template, request, redirect, url_for, session, flash, make_response
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import or_
from flask_migrate import Migrate
from werkzeug.utils import secure_filename  
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
import os
import random
import uuid
import string
import re
from dotenv import load_dotenv
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from io import BytesIO



# Load environment variables
load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'static/images'

db = SQLAlchemy(app)
migrate = Migrate(app, db)

def clear_cart():
    user_id = session.get('user_id')
    session_id = get_session_id()

    if user_id:
        CartItem.query.filter_by(user_id=user_id).delete()
    else:
        CartItem.query.filter_by(session_id=session_id).delete()

    db.session.commit()


# User Model
class User(db.Model):
    __tablename__ = 'user'  # Make sure this matches the table name
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), unique=True, nullable=False) 
    phone = db.Column(db.String(15), nullable=False)
    user_type = db.Column(db.String(10), default='user')

    orders = db.relationship('Order', back_populates='user', lazy=True)
    addresses = db.relationship('Address', backref='user', lazy=True)


# Product Model
class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.String(500), nullable=True)
    price = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(50), nullable=False)
    stock = db.Column(db.Integer, nullable=False)
    image = db.Column(db.String(200), nullable=False)

    def __repr__(self):
        return f'<Product {self.name}>'

# CartItem Model
class CartItem(db.Model):
    __tablename__ = 'cart_item'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    price = db.Column(db.Float, nullable=False)
    quantity = db.Column(db.Integer, default=1)
    total = db.Column(db.Float, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)  # Optional for logged-in users
    session_id = db.Column(db.String(100), nullable=True)  # Used for guest users
    image = db.Column(db.String(200), nullable=False)  # Add image field

    def __repr__(self):
        return f'<CartItem {self.name}>'


# Contact Model
class Contact(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    message = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, default=db.func.current_timestamp())

# OrderItem Model
class OrderItem(db.Model):
    __tablename__ = 'order_item'
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=False)  # Foreign key to Order
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    product_name = db.Column(db.String(100), nullable=False)
    product_image = db.Column(db.String(100), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    price = db.Column(db.Float, nullable=False)
    total = db.Column(db.Float, nullable=False)

    def __repr__(self):
        return f'<OrderItem {self.product_name}>'



# Order Model
class Order(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.Integer, primary_key=True)
    order_number = db.Column(db.String(8), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)  # Use 'user.id'
    address_id = db.Column(db.Integer, db.ForeignKey('addresses.id'), nullable=True)
    total_amount = db.Column(db.Float, nullable=False)
    delivery_date = db.Column(db.DateTime, nullable=False)
    placed_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    order_items = db.relationship('OrderItem', backref='order', lazy=True)
    user = db.relationship('User', back_populates='orders')  # Ensure it matches with the User model
    address = db.relationship('Address', backref='orders', lazy=True)

    def __init__(self, order_number, user_id, total_amount, delivery_date, address_id=None):
        self.order_number = order_number
        self.user_id = user_id
        self.total_amount = total_amount
        self.delivery_date = delivery_date
        self.address_id = address_id



class Address(db.Model):
    __tablename__ = 'addresses'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)  # Use 'user.id'
    address_line = db.Column(db.String(255), nullable=False)
    city = db.Column(db.String(100), nullable=False)
    state = db.Column(db.String(100), nullable=False)
    postal_code = db.Column(db.String(20), nullable=False)
    country = db.Column(db.String(100), nullable=False)
    address_type = db.Column(db.Enum('default', 'secondary'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# Utility function to get cart item count
def get_cart_item_count():
    user_id = session.get('user_id')  # Get user_id from the session
    session_id = get_session_id()  # Get session ID

    if user_id:
        # Count items for logged-in users
        return CartItem.query.filter_by(user_id=user_id).count()
    else:
        # Count items for guest users
        return CartItem.query.filter_by(session_id=session_id).count()


# Centralized rendering function
def render_with_cart(template, **context):
    context['cart_count'] = get_cart_item_count()
    return render_template(template, **context)

def get_session_id():
    if 'session_id' not in session:
        session['session_id'] = str(uuid.uuid4())  # Generate unique session ID
    return session['session_id']


# Route for Home Page
@app.route('/')
def home():
    products = Product.query.all()
    user = session.get('user')
    return render_with_cart('index.html', products=products, user=user)

@app.route('/profile')
def profile():
    user = session.get('user')
    user_d = User.query.get(session.get('user_id'))
    return render_with_cart('profile.html', user=user,  user_d=user_d)


# Route for adding a product
@app.route('/add-product', methods=['GET', 'POST'])
def add_product():
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        price = float(request.form['price'])
        category = request.form['category']
        stock = int(request.form['stock'])
        image = request.files['image']

        image_filename = 'default.jpg'  # Default image if not provided
        if image:
            image_filename = secure_filename(image.filename)
            image.save(os.path.join(app.config['UPLOAD_FOLDER'], image_filename))

        new_product = Product(name=name, description=description, price=price, category=category, stock=stock, image=image_filename)
        try:
            db.session.add(new_product)
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            flash(f'Error adding product: {str(e)}', 'danger')
        return redirect(url_for('shop'))

    return render_with_cart('add_product.html')

# Route for Shop
@app.route('/shop')
def shop():
    products = Product.query.all()
    user = session.get('user')
    return render_with_cart('shop.html', products=products, user=user)

# Route for adding items to the cart
# Route for adding items to the cart
@app.route('/add_to_cart/<int:product_id>')
def add_to_cart(product_id):
    product = Product.query.get_or_404(product_id)

    # Get user ID and session ID
    user_id = session.get('user_id')
    session_id = get_session_id()

    if product.stock > 0:
        # Determine which ID to use for the cart item
        cart_item = (CartItem.query
                     .filter_by(product_id=product_id)
                     .filter((CartItem.user_id == user_id) | (CartItem.session_id == session_id))
                     .first())

        if cart_item:
            cart_item.quantity += 1
            cart_item.total = cart_item.price * cart_item.quantity
        else:
            # Create new CartItem
            cart_item = CartItem(
                name=product.name,
                product_id=product.id,
                price=product.price,
                quantity=1,
                total=product.price,
                user_id=user_id,  # Set user_id if logged in
                session_id=session_id if not user_id else None,  # Set session_id if not logged in
                image=product.image
            )
            db.session.add(cart_item)

        # Decrease product stock
        product.stock -= 1
        db.session.commit()
        flash('Item added to cart!', 'success')
    else:
        flash('Product out of stock!', 'danger')
    return redirect(request.referrer or url_for('shop'))



# Route for displaying the cart
@app.route('/cart')
def cart():
    user_id = session.get('user_id')
    session_id = get_session_id()

    if user_id:
        # Retrieve cart items for logged-in user
        cart_items = CartItem.query.filter_by(user_id=user_id).all()
    else:
        # Retrieve cart items for guest user
        cart_items = CartItem.query.filter_by(session_id=session_id).all()

    total_amount = sum(item.total for item in cart_items)
    user = session.get('user')
    return render_with_cart('cart.html', cart_items=cart_items, total_amount=total_amount, user=user)


# Route for removing an item from the cart
@app.route('/remove_from_cart/<int:item_id>')
def remove_from_cart(item_id):
    item = CartItem.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return redirect(url_for('cart'))

# Route for user login
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        user = User.query.filter_by(username=username).first()
        
        # Check if user exists and password matches
        if user and check_password_hash(user.password, password):
            session['user'] = user.username
            session['user_id'] = user.id
            session['user_type'] = user.user_type

            # Check if the user is an admin
            if user.user_type ==  'admin':
                flash('Admin login successful!', 'success')
                return redirect(url_for('admin'))  # Redirect to admin page
            
            flash('Login successful!', 'success')
            return redirect(url_for('home'))
        else:
            flash('Invalid credentials', 'danger')
    return render_template('login.html')

# Route for Admin Page
@app.route('/admin')
def admin():
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))
    products= Product.query.all()
    
    return render_template('admin.html',  products=products)

from flask import redirect, session, flash, url_for

@app.route('/admin/orders')
def admin_orders():
    # Check if user is logged in and is admin
    user_id = session.get('user_id')
    if not user_id:
        flash('Please log in to access this page.', 'warning')
        return redirect(url_for('login'))

    user = User.query.get(user_id)
    if user.user_type != 'admin':
        flash('You do not have permission to access this page.', 'danger')
        return redirect(url_for('home'))

    # Fetch all orders for admin view
    orders = Order.query.all()
    return render_template('admin_order.html', orders=orders)


# Route for signup
@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        phone = request.form['phone']

        existing_user = User.query.filter_by(username=username).first()
        existing_email = User.query.filter_by(email=email).first()
        if existing_user:
            flash('Username already exists. Please choose a different one.', 'error')
            return redirect(url_for('signup'))
        if existing_email:
            flash('Email already exists. Please use a different one.', 'error')
            return redirect(url_for('signup'))

        hashed_password = generate_password_hash(password)
        new_user = User(username=username, password=hashed_password, email=email, phone=phone)

        try:
            db.session.add(new_user)
            db.session.commit()
            flash('Signup successful! Please log in.', 'success')
            return redirect(url_for('login'))
        except Exception as e:
            db.session.rollback()
            flash('An error occurred while creating your account. Please try again.', 'error')
            return redirect(url_for('signup'))

    return render_template('signup.html')

# Logout
@app.route('/logout')
def logout():
    session.pop('user', None)
    session.pop('user_id', None)  # Remove user_id from session
    flash('You have successfully logged out.', 'info')
    return redirect(url_for('home'))

# Route for Contact
@app.route('/contact')
def contact():
    user = session.get('user')
    return render_with_cart('contact.html', user=user)

# Route for submitting contact form
@app.route('/submit_contact', methods=['POST'])
def submit_contact():
    name = request.form.get('name')
    email = request.form.get('email')
    message = request.form.get('message')

    new_contact = Contact(name=name, email=email, message=message)
    db.session.add(new_contact)
    db.session.commit()

    flash('Your message has been sent successfully!', 'success')
    return redirect(url_for('contact'))


# Route for Search
@app.route('/search', methods=['GET', 'POST'])
def search():
    user = session.get('user')
    products = []  # Initialize products to an empty list
    found = False   # Flag to check if any products are found

    # Handle search via POST request
    if request.method == 'POST':
        query = request.form.get('query', '').strip()  # Get the query and strip whitespace, default to empty string
    else:
        # Handle category search via GET request
        query = request.args.get('query', '').strip()  # Default to empty string

    # Normalize spaces: replace multiple spaces with a single space
    query = re.sub(r'\s+', ' ', query)

    if query:
        # Split the query into individual words
        search_terms = query.split(' ')
        
        # Create a search filter for each term
        filters = [or_(
            Product.name.ilike(f'%{term}%'),
            Product.category.ilike(f'%{term}%')
        ) for term in search_terms]

        # Combine filters with OR logic
        products = Product.query.filter(or_(*filters)).all()
        found = len(products) > 0  # Set flag based on whether products were found

    return render_with_cart('shop.html', products=products, user=user, found=found)




@app.route('/place_order', methods=['GET', 'POST'])
def place_order():
    if request.method == 'POST':
        user_id = session.get('user_id')
        session_id = get_session_id()

        if user_id:
            # Retrieve cart items for logged-in user
            cart_items = CartItem.query.filter_by(user_id=user_id).all()
        else:
            # Retrieve cart items for guest user
            cart_items = CartItem.query.filter_by(session_id=session_id).all()

        if not cart_items:
            flash('Your cart is empty.', 'info')
            return redirect(url_for('cart'))

        total_amount = sum(item.total for item in cart_items)
        delivery_date = datetime.now() + timedelta(days=5)
        order_number = generate_unique_order_number()

        # Create a new Order
        new_order = Order(order_number=order_number, user_id=user_id, total_amount=total_amount, delivery_date=delivery_date)

        try:
            db.session.add(new_order)
            db.session.flush()  # Flush to get the order ID for order items

            # Create OrderItems for each CartItem
            for cart_item in cart_items:
                order_item = OrderItem(
                    order_id=new_order.id,
                    product_id=cart_item.product_id,
                    product_name=cart_item.name,
                    product_image=cart_item.image,
                    quantity=cart_item.quantity,
                    price=cart_item.price,
                    total=cart_item.total
                )
                db.session.add(order_item)

            db.session.commit()  # Commit all changes
            clear_cart()  # Clear the cart after placing the order
            flash('Order placed successfully!', 'success')
            return redirect(url_for('order_confirmation'))

        except IntegrityError:
            db.session.rollback()
            flash('An error occurred while placing your order. Please try again.', 'danger')

    return render_with_cart('user_details.html')

@app.route('/order_confirmation', methods=['GET', 'POST'])
def order_confirmation():
    user = session.get('user')
    user_id = session.get('user_id')  # Ensure user is logged in
    if not user_id:
        flash("Please log in to continue.", "danger")
        return redirect(url_for('login'))

    # Fetch user's addresses
    addresses = Address.query.filter_by(user_id=user_id).all()

    if request.method == 'POST':
        selected_address_id = request.form.get('address_id')
        add_new_address = request.form.get('add_new_address')  # Checkbox or flag to indicate if a new address will be added
        
        # If a new address is to be added, collect the details
        if add_new_address:
            new_address_line = request.form.get('new_address_line')
            new_city = request.form.get('new_city')
            new_state = request.form.get('new_state')
            new_postal_code = request.form.get('new_postal_code')
            new_country = request.form.get('new_country')

            if not new_address_line or not new_city or not new_state or not new_postal_code or not new_country:
                flash("Please provide all address details.", "danger")
                return redirect(url_for('order_confirmation'))

            # Add new address as secondary
            new_address = Address(
                user_id=user_id,
                address_line=new_address_line,
                city=new_city,
                state=new_state,
                postal_code=new_postal_code,
                country=new_country,
                address_type='secondary'  # Set as secondary address
            )
            db.session.add(new_address)
            db.session.commit()

            selected_address_id = new_address.id  # Use the new address ID for the order

        # If a primary address is selected
        if selected_address_id:
            order = Order.query.filter_by(user_id=user_id).order_by(Order.id.desc()).first()

            if order:
                # Update order with the selected address
                order.address_id = selected_address_id  # Set the foreign key to the address ID
                try:
                    db.session.commit()  # Save the updated order
                    clear_cart()  # Empty the cart after order confirmation
                    flash("Order placed successfully!", "success")
                    return redirect(url_for('order_success', order_number=order.order_number))
                except IntegrityError:
                    db.session.rollback()
                    flash("An error occurred while confirming your order. Please try again.", "danger")
            else:
                flash("No active order found. Please try again.", "danger")
                return redirect(url_for('cart'))

    return render_with_cart('order_confirmation.html', addresses=addresses, user=user)

@app.route('/order_success/<order_number>')
def order_success(order_number):
    # Retrieve the specific order by its order number
    order = Order.query.filter_by(order_number=order_number).first_or_404()  # Retrieve order by order_number or return 404
    cart_count = get_cart_item_count()
    # Retrieve the items related to this order
    order_items = OrderItem.query.filter_by(order_id=order.id).all()  # Get related order items
    
    user = session.get('user')  # Get the current user from the session

    # Render the template with all the necessary data
    return render_template('order_success.html', order=order, order_items=order_items, user=user, cart_count=cart_count)




# Function to generate order number
def generate_order_number():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))

def generate_unique_order_number():
    while True:
        order_number = generate_order_number()
        if not Order.query.filter_by(order_number=order_number).first():
            break
    return order_number


# Route for Categories
@app.route('/categories')
def categories():
    cart_count = get_cart_item_count()
    products = Product.query.all()
    user = session.get('user')
    return render_template('categories.html', user=user,  products=products, cart_count=cart_count)


@app.route('/checkout')
def checkout():
    user = session.get('user')
    user_id = session.get('user_id')
    session_id = get_session_id()
    if user_id:
        # Retrieve cart items for logged-in user
        cart_items = CartItem.query.filter_by(user_id=user_id).all()
    else:
        # Retrieve cart items for guest user
        cart_items = CartItem.query.filter_by(session_id=session_id).all()
    total_amount = sum(item.total for item in cart_items)
    user = session.get('user')
    return render_with_cart('checkout.html', cart_items=cart_items, total_amount=total_amount, user=user)

@app.route('/update_cart/<int:item_id>', methods=['POST'])
def update_cart(item_id):
    """Update the quantity of a cart item."""
    try:
        # Retrieve new quantity from the form input
        new_quantity = int(request.form['quantity'])
        if new_quantity < 1:
            flash('Quantity must be at least 1.', 'warning')
            return redirect(url_for('cart'))

        # Determine if the user is logged in or using session-based cart
        user_id = session.get('user_id')
        session_id = get_session_id()

        # Query the cart item by ID and user/session association
        cart_item = CartItem.query.filter_by(id=item_id).filter(
            (CartItem.user_id == user_id) | (CartItem.session_id == session_id)
        ).first()

        if cart_item:
            # Update quantity and total price
            cart_item.quantity = new_quantity
            cart_item.total = cart_item.price * new_quantity

            db.session.commit()
            flash('Cart updated successfully!', 'success')
        else:
            flash('Cart item not found.', 'danger')

    except ValueError:
        flash('Invalid quantity. Please enter a valid number.', 'danger')

    # Redirect back to the cart page
    return redirect(url_for('cart'))

@app.route('/orders')
def orders():
    user = session.get('user')
    user_id = session['user_id']
    cart_count = get_cart_item_count()
    
    if 'user_id' not in session:
        flash('Please log in to view your orders.', 'danger')
        return redirect(url_for('login'))

    # Fetch all orders placed by the user, along with the related items
    orders = Order.query.filter_by(user_id=user_id).all()

    # Verify if orders contain related items
    for order in orders:
        order.items = OrderItem.query.filter_by(order_id=order.id).all()

    return render_template('orders.html', orders=orders, user=user, cart_count=cart_count)

@app.route('/generate_invoice/<order_number>')
def generate_invoice(order_number):
    # Retrieve the order using order_number instead of order_id
    order = Order.query.filter_by(order_number=order_number).first_or_404()
    order_items = OrderItem.query.filter_by(order_id=order.id).all()

    # Create an in-memory PDF using BytesIO
    pdf_stream = BytesIO()
    c = canvas.Canvas(pdf_stream, pagesize=letter)

    # Add content to the PDF (Header)
    c.setFont("Helvetica-Bold", 16)
    c.drawString(100, 750, f"Invoice for Order #{order.order_number}")  # Use order_number for clarity

    # Add Order Items to the PDF
    c.setFont("Helvetica", 12)
    y_position = 700  # Y-position to start listing items
    for item in order_items:
        c.drawString(100, y_position, f"{item.product_name} - {item.quantity} x ₹{item.price} = ₹{item.total}")
        y_position -= 20  # Move down for the next item

    # Add Total Amount
    c.setFont("Helvetica-Bold", 14)
    c.drawString(100, y_position - 20, f"Total: ₹{order.total_amount}")

    # Finalize the PDF
    c.showPage()
    c.save()
    pdf_stream.seek(0)  # Reset stream pointer to the beginning

    # Create Flask response for PDF download/print
    response = make_response(pdf_stream.read())
    response.headers['Content-Type'] = 'application/pdf'
    response.headers['Content-Disposition'] = f'inline; filename=invoice_{order.order_number}.pdf'  # Use order_number in the filename
    return response

@app.route('/invoice/<order_number>')
def invoice(order_number):
    # Retrieve the order using order_number instead of order_id
    order = Order.query.filter_by(order_number=order_number).first_or_404()
    order_items = OrderItem.query.filter_by(order_id=order.id).all()

    # Render the invoice template with the order and order items
    return render_template('invoice.html', order=order, order_items=order_items)


# Run the application
if __name__ == '__main__':
    app.run(debug=True)
