# Falotier: a 'real-life' state management PoC

The purpose of this PoC is to implement all real life app scenarios and see if the selected state management library elegantly supports all the needed mutations.

The select state management library: [Riverpod](https://pub.dev/packages/riverpod).

I am a `Riverpod` enthusiast, but coming from a MVVM oriented world, I had my share of doubts and interrogations.
I read a lot of example, but I couldn't find a sample app that covers the scenarios I always meet when I am building an app for a client.

So I decided to see If I could build an app that supports the most classic use-cases from real-life app with `Riverpod`.
And here is the result.

## Supported use-cases

In Falotier, I try to support as much real-life use cases.\
You have a list of streets with a street lamp which is lit or not.\
As a Falotier:
* You can assign new streets to you by taping to the `Add Street` button,
* You can lighten your burden by taping on the cross of an item,
* You must lit the street lamp when the night is coming by taping on the street lamp bulb,
* You must turn off the street lamp when the night is over with the same gesture.


### Loading from scratch

The loading of an empty screen.\
If the loading is successful, we display our result.\
Or we display an informative message to the user and we give him the possibility to retry.

![loading home](docs/loading_home.jpg)

### Riverpod implementation

Coming soon...For now feel free to browse the code.

### Refreshing

When an item is already loaded and we want to refresh it.\
Typically the `pull-to-refresh` of a list.\
If the refresh is successful, we update our whole list.\
It there is an error during the refresh, we show a `SnackBar`.

![refreshing home](docs/refresh_home.jpg)

### Riverpod implementation

Coming soon...For now feel free to browse the code.

### List update 

#### Adding a new item in the list
We tap on the `FloatingActionButton`, it opens a modal displaying our available streets.\
We select one, we call an `update` method on our server side.\
During the call, we show an overlay.\
If the remote call is successful we update our list state and close the modal.\
If there was a error during the call, we display a `SnackBar` to our user.

#### Riverpod implementation

Coming soon...For now feel free to browse the code.

![add item to a lits](docs/add_item.jpg)

#### Removing an item from a list

We tap on an item cross.\
We call a `remove` method on our server side.\
During the call, we transform our cross icon to a loading widget.\
If the remote call is successful we update our list state and the item is removed.\
If there was a error during the call, we display a `SnackBar` to our user.

![video]()

#### Riverpod implementation

Coming soon...For now feel free to browse the code.

### Item details update

By taping to a list item, we navigate to a street.\
By taping on the street lamp, we toggle its light.\
This is calling a method on the server side.\
During the remote call, we display an animation of the light which is growing or fading.\
If it fails, the previous state is restored and we display a `SnackBar`.

![update an item](docs/lamp_details_update.jpg)

Our architecture must of course propagate the new immutable item to the item list.

![video]()

## The application architecture

Coming soon...For now feel free to browse the code.

## The design

I implemented a theme with a separate flutter project called falotier_design.\
It's like I had a design system and implemented it with a theme, giving semantics to colors, spaces, text, etc...\
I also have a collection of `Widgets` in this library that I use in my apps.

For this I followed [Aloïs Deniel](https://github.com/aloisdeniel) guidance.\
Please have a look at [this great video](https://www.youtube.com/watch?v=lTy8odHcS5s).

You can also [check its repo](https://github.com/aloisdeniel/asgard_shop).

### The street details composition

The street detail screen is built dynamically with composition of image and stacks of gradients.

Coming soon...For now feel free to browse the code.

## The story behind

Coming soon...For now feel free to imagine it.